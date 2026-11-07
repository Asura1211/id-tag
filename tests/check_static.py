from pathlib import Path
import json
root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'manifest.webmanifest').read_text())
required = ['index.html', 'css/app.css', 'js/app.js', 'js/update.js', 'sw.js', 'icon-192.png', 'icon-512.png']
for name in required:
    path = root / name
    assert path.is_file() and not path.is_symlink(), name
html = (root / 'index.html').read_text()
for name in ['css/app.css', 'js/app.js', 'js/update.js', 'manifest.webmanifest']:
    assert name in html, name
assert {'192x192', '512x512'} <= {i['sizes'] for i in manifest['icons']}
assert "id-tag-demo-local-v5" in (root / 'sw.js').read_text()
print('Static files and PWA manifest OK')
