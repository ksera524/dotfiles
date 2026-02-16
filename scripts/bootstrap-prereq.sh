#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

log() {
  printf '%s\n' "$1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix..."
  sh <(curl --proto '=https' --tlsv1.2 -L https://install.determinate.systems/nix) install --no-confirm
else
  log "Nix already installed"
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
