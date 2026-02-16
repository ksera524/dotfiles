#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [[ "${1:-}" == "--legacy" ]]; then
  shift
  if [[ "$(uname -s)" == "Darwin" ]]; then
    exec "$SCRIPT_DIR/mac.sh" "$@"
  fi
  exec "$SCRIPT_DIR/wsl.sh" "$@"
fi

exec "$SCRIPT_DIR/scripts/switch.sh" "$@"
