#!/bin/bash

log_info() { printf '%s\n' "INFO: $1"; }
log_success() { printf '%s\n' "OK: $1"; }
log_warning() { printf '%s\n' "WARN: $1"; }
log_error() { printf '%s\n' "ERROR: $1"; }

cleanup_tmp() {
  for tmp_file in "${TMP_FILES[@]:-}"; do
    [ -f "$tmp_file" ] && rm -f "$tmp_file"
  done
}

setup_tmp_cleanup() {
  TMP_FILES=()
  trap cleanup_tmp EXIT
}

register_tmp() {
  TMP_FILES+=("$1")
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

is_wsl() {
  if ! is_linux; then
    return 1
  fi
  grep -qi microsoft /proc/version 2>/dev/null || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

backup_path() {
  local target=$1
  local timestamp
  timestamp=$(date +%Y%m%d%H%M%S)
  mv "$target" "${target}.backup.${timestamp}"
}

link_path() {
  local src=$1
  local dest=$2

  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    backup_path "$dest"
  fi
  ln -sfn "$src" "$dest"
}

parse_args() {
  DRY_RUN=false
  SKIP_WSL_CHECK=false
  CI_MODE=false

  for arg in "$@"; do
    case $arg in
      --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Bootstrap script for WSL/macOS development environment"
        echo ""
        echo "Options:"
        echo "  --help, -h       Show this help message"
        echo "  --dry-run        Run in dry-run mode (no actual changes)"
        echo "  --skip-wsl-check Skip WSL environment check"
        echo "  --ci             Run in CI mode (skip WSL-only steps)"
        echo ""
        exit 0
        ;;
      --dry-run)
        DRY_RUN=true
        log_info "Running in DRY-RUN mode (no actual changes will be made)"
        ;;
      --skip-wsl-check)
        SKIP_WSL_CHECK=true
        ;;
      --ci)
        CI_MODE=true
        SKIP_WSL_CHECK=true
        ;;
    esac
  done

  if [ -n "${CI:-}" ]; then
    CI_MODE=true
    SKIP_WSL_CHECK=true
  fi
}

setup_dotfiles_dir() {
  local start_dir=$1
  DOTFILES_DIR="$start_dir"
  cd "$DOTFILES_DIR" || exit 1
  log_info "Using dotfiles at: $DOTFILES_DIR"

  if [ "${CI_MODE:-false}" = true ]; then
    log_info "Skipping dotfiles relocation in CI mode"
    return
  fi

  GHQ_ROOT=$(git config --global --get ghq.root 2>/dev/null || true)
  if [ -z "$GHQ_ROOT" ]; then
    GHQ_ROOT="$HOME/src"
  fi
  GHQ_ROOT="${GHQ_ROOT/#\~/$HOME}"
  ORIGIN_URL=$(git -C "$DOTFILES_DIR" config --get remote.origin.url 2>/dev/null || true)
  if [ -n "$ORIGIN_URL" ]; then
    GHQ_HOST=""
    GHQ_PATH=""
    if [[ "$ORIGIN_URL" =~ ^git@([^:]+):(.+)$ ]]; then
      GHQ_HOST="${BASH_REMATCH[1]}"
      GHQ_PATH="${BASH_REMATCH[2]}"
    elif [[ "$ORIGIN_URL" =~ ^https?://([^/]+)/(.+)$ ]]; then
      GHQ_HOST="${BASH_REMATCH[1]}"
      GHQ_PATH="${BASH_REMATCH[2]}"
    fi

    if [ -n "$GHQ_HOST" ] && [ -n "$GHQ_PATH" ]; then
      GHQ_PATH="${GHQ_PATH%.git}"
      GHQ_TARGET="$GHQ_ROOT/$GHQ_HOST/$GHQ_PATH"
      if [ "$DOTFILES_DIR" != "$GHQ_TARGET" ]; then
        if [ -d "$GHQ_TARGET/.git" ]; then
          TARGET_ORIGIN=$(git -C "$GHQ_TARGET" config --get remote.origin.url 2>/dev/null || true)
          if [ "$TARGET_ORIGIN" = "$ORIGIN_URL" ]; then
            log_info "Using existing ghq repo at: $GHQ_TARGET"
            ln -sfn "$GHQ_TARGET" "$HOME/dotfiles"
            DOTFILES_DIR="$GHQ_TARGET"
            cd "$DOTFILES_DIR" || exit 1
          else
            log_warning "ghq target exists with different remote: $GHQ_TARGET"
          fi
        else
          log_info "Relocating dotfiles into ghq root..."
          mkdir -p "$(dirname "$GHQ_TARGET")"
          mv "$DOTFILES_DIR" "$GHQ_TARGET"
          ln -sfn "$GHQ_TARGET" "$HOME/dotfiles"
          DOTFILES_DIR="$GHQ_TARGET"
          cd "$DOTFILES_DIR" || exit 1
          log_success "dotfiles moved to $DOTFILES_DIR"
        fi
      fi
    fi
  fi
}
