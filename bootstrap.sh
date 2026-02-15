#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

parse_args "$@"

printf '\n'
printf '%s\n' "Development Environment Setup"
printf '\n'

if is_macos; then
  log_info "Detected macOS"
  exec "$SCRIPT_DIR/mac.sh" "$@"
fi

if is_linux; then
  if is_wsl; then
    log_info "Detected WSL"
    exec "$SCRIPT_DIR/wsl.sh" "$@"
  fi

  log_warning "WSL not detected. This setup is optimized for WSL."
  if [ "$SKIP_WSL_CHECK" = true ] || [ "$CI_MODE" = true ] || [ "$DRY_RUN" = true ]; then
    log_info "Proceeding with WSL setup on non-WSL Linux due to flags"
    exec "$SCRIPT_DIR/wsl.sh" "$@"
  else
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      exec "$SCRIPT_DIR/wsl.sh" "$@"
    fi
    exit 1
  fi
fi

log_error "Unsupported OS. This bootstrap supports WSL/Linux and macOS."
exit 1
