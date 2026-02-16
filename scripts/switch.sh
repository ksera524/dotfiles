#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

if [ "$EUID" -eq 0 ]; then
  echo "Error: Do not run this script as root (sudo). Run as a normal user."
  exit 1
fi

"$SCRIPT_DIR/scripts/bootstrap-prereq.sh"
exec nix run --impure "$SCRIPT_DIR#switch" -- "$@"
