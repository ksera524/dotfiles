#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
NIX_PROFILE_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
NIX_FALLBACK_BIN="/nix/var/nix/profiles/default/bin/nix"

resolve_nix_bin() {
  if command -v nix >/dev/null 2>&1; then
    NIX_BIN="$(command -v nix)"
    return 0
  fi

  if [[ -f "$NIX_PROFILE_SCRIPT" ]]; then
    # shellcheck source=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    source "$NIX_PROFILE_SCRIPT"
  fi

  if command -v nix >/dev/null 2>&1; then
    NIX_BIN="$(command -v nix)"
    return 0
  fi

  if [[ -x "$NIX_FALLBACK_BIN" ]]; then
    NIX_BIN="$NIX_FALLBACK_BIN"
    return 0
  fi

  return 1
}

if [ "$EUID" -eq 0 ]; then
  echo "Error: Do not run this script as root (sudo). Run as a normal user."
  exit 1
fi

"$SCRIPT_DIR/scripts/bootstrap-prereq.sh"

if ! resolve_nix_bin; then
  echo "Error: nix command is not available after bootstrap." >&2
  echo "Run: source $NIX_PROFILE_SCRIPT" >&2
  echo "Or open a new terminal and run ./bootstrap.sh again." >&2
  exit 1
fi

exec "$NIX_BIN" run --impure "$SCRIPT_DIR#switch" -- "$@"
