#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

log() {
  printf '%s\n' "$1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
NIX_PROFILE_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
NIX_FALLBACK_BIN="/nix/var/nix/profiles/default/bin/nix"

ensure_nix_available() {
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

ensure_nix_available || true

if ! ensure_nix_available; then
  log "Installing Nix..."
  sh <(curl --proto '=https' --tlsv1.2 -L https://install.determinate.systems/nix) install --no-confirm
  ensure_nix_available || true
else
  log "Nix already installed"
fi

if ! ensure_nix_available; then
  log "Error: nix command is not available in this shell."
  log "Run: source $NIX_PROFILE_SCRIPT"
  log "Or open a new terminal and run ./bootstrap.sh again."
  exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools are required: xcode-select --install"
    exit 1
  fi
fi

if [[ -f "$SCRIPT_DIR/home.local.nix.sample" ]]; then
  mkdir -p "$HOME/.config/dotfiles"
  if [[ ! -f "$HOME/.config/dotfiles/home.local.nix" ]]; then
    cp "$SCRIPT_DIR/home.local.nix.sample" "$HOME/.config/dotfiles/home.local.nix"
    log "Created $HOME/.config/dotfiles/home.local.nix from sample"
  fi
fi

log "Prerequisites are ready"
