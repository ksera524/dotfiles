#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
NIX_PROFILE_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
NIX_FALLBACK_BIN="/nix/var/nix/profiles/default/bin/nix"

log() {
  printf '%s\n' "$1"
}

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

current_login_shell() {
  local shell_entry

  if [[ "$(uname -s)" == "Darwin" ]]; then
    shell_entry="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null || true)"
    shell_entry="${shell_entry#UserShell: }"
  else
    shell_entry="$(getent passwd "$USER" 2>/dev/null || true)"
    shell_entry="${shell_entry##*:}"
  fi

  printf '%s\n' "$shell_entry"
}

resolve_fish_shell() {
  local shell_path

  if [[ -f /etc/shells ]]; then
    while IFS= read -r shell_path; do
      if [[ "$shell_path" == */fish && -x "$shell_path" ]]; then
        printf '%s\n' "$shell_path"
        return 0
      fi
    done < /etc/shells
  fi

  command -v fish 2>/dev/null || return 1
}

ensure_fish_default_shell() {
  local target_shell
  local login_shell

  if ! target_shell="$(resolve_fish_shell)"; then
    log "fish is not available yet. Skipping default shell switch."
    return 0
  fi

  login_shell="$(current_login_shell)"
  if [[ "$login_shell" == */fish ]]; then
    log "Default shell is already fish: $login_shell"
    return 0
  fi

  log "Setting default shell to fish: $target_shell"
  if chsh -s "$target_shell"; then
    log "Default shell updated. fish will be used in new login sessions."
    return 0
  fi

  log "Could not switch default shell automatically."
  if [[ -f /etc/shells ]]; then
    log "If chsh reported an invalid shell, add $target_shell to /etc/shells first."
  fi
  log "Run manually: chsh -s \"$target_shell\""
  log "Current login shell remains: ${login_shell:-unknown}"
  return 0
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

"$NIX_BIN" run --impure "$SCRIPT_DIR#switch" -- "$@"
ensure_fish_default_shell
