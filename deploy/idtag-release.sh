#!/bin/bash
# Install as root-owned /usr/local/sbin/idtag-release; never execute from a Git checkout.
set -euo pipefail
[[ $# == 1 && "$1" =~ ^[0-9a-f]{40}$ ]] || { echo 'Invalid revision' >&2; exit 2; }
sha=$1
exec 9>/run/lock/hitlcj-deploy.lock
flock -w 180 9 || { echo 'Another deployment is running' >&2; exit 1; }
repo=/opt/idtag/repo
export GIT_SSH_COMMAND='ssh -i /home/idtag-deploy/.ssh/github_readonly -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes'
sudo -u idtag-deploy --preserve-env=GIT_SSH_COMMAND git -C "$repo" fetch --quiet origin main
actual=$(sudo -u idtag-deploy git -C "$repo" rev-parse FETCH_HEAD)
[[ "$sha" == "$actual" ]] || { echo 'main moved; refusing obsolete deployment' >&2; exit 1; }
staging=$(mktemp -d /tmp/idtag-stage.XXXXXX)
release=''
old=$(readlink -f /var/www/idtag-live)
switched=0
cleanup() {
  result=$?
  if (( result != 0 && switched == 1 )); then
    ln -s "$old" /var/www/idtag-live.rollback
    mv -Tf /var/www/idtag-live.rollback /var/www/idtag-live
    echo 'Deployment failed; previous version restored' >&2
  fi
  rm -rf "$staging"
  exit "$result"
}
trap cleanup EXIT
chown idtag-deploy:idtag-deploy "$staging"
sudo -u idtag-deploy git -C "$repo" archive "$sha" index.html css/app.css js/app.js js/update.js manifest.webmanifest sw.js icon-192.png icon-512.png | sudo -u idtag-deploy tar -xf - -C "$staging"
if find "$staging" -type l -print -quit | grep -q .; then echo 'Symlinks forbidden' >&2; exit 1; fi
for file in index.html css/app.css js/app.js js/update.js manifest.webmanifest sw.js icon-192.png icon-512.png; do
  [[ -f "$staging/$file" && ! -L "$staging/$file" ]] || { echo "Missing $file" >&2; exit 1; }
done
release=$(mktemp -d "/var/www/idtag-releases/${sha}.XXXXXX")
cp -R "$staging/." "$release/"
python3 - "$release" "$sha" <<'PY'
from pathlib import Path
import json,sys
p=Path(sys.argv[1]); sha=sys.argv[2]
sw=p/'sw.js'; value=sw.read_text(); marker='id-tag-demo-local-v5'
assert value.count(marker)==1
sw.write_text(value.replace(marker,'id-tag-demo-'+sha))
(p/'version.json').write_text(json.dumps({'commit':sha})+'\n')
PY
chmod -R a+rX "$release"
ln -s "$release" /var/www/idtag-live.next
mv -Tf /var/www/idtag-live.next /var/www/idtag-live
switched=1
for path in / /sw.js /manifest.webmanifest /version.json; do
  curl --noproxy '*' --silent --show-error --fail --max-time 15 --resolve nfc.hitlcj.top:443:127.0.0.1 "https://nfc.hitlcj.top$path" -o /dev/null
done
curl --noproxy '*' -fsS --resolve nfc.hitlcj.top:443:127.0.0.1 https://nfc.hitlcj.top/version.json | grep -Fq "$sha"
expected=$(sha256sum "$release/index.html" | cut -d' ' -f1)
served=$(curl --noproxy '*' -fsS --resolve nfc.hitlcj.top:443:127.0.0.1 https://nfc.hitlcj.top/ | sha256sum | cut -d' ' -f1)
[[ "$expected" == "$served" ]]
switched=0
echo "Deployed $sha"
