#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

exec "$SCRIPT_DIR/scripts/switch.sh" "$@"
