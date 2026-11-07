#!/bin/bash
set -euo pipefail
[[ "${SSH_ORIGINAL_COMMAND:-}" =~ ^deploy\ ([0-9a-f]{40})$ ]] || { echo 'Only deploy <commit> is allowed' >&2; exit 2; }
exec sudo -n /usr/local/sbin/idtag-release "${BASH_REMATCH[1]}"
