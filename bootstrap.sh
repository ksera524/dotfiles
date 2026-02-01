#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# Bootstrap Script for WSL Ubuntu Environment
# One-shot setup for development environment with mise, fish, docker, etc.
# ============================================================================

log_info() { printf '%s\n' "INFO: $1"; }
log_success() { printf '%s\n' "OK: $1"; }
log_warning() { printf '%s\n' "WARN: $1"; }
log_error() { printf '%s\n' "ERROR: $1"; }

TMP_FILES=()
cleanup_tmp() {
  for tmp_file in "${TMP_FILES[@]:-}"; do
    [ -f "$tmp_file" ] && rm -f "$tmp_file"
  done
}
trap cleanup_tmp EXIT

is_wsl() {
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

# Parse arguments
DRY_RUN=false
SKIP_WSL_CHECK=false
CI_MODE=false
SHELL_MSG=""
for arg in "$@"; do
  case $arg in
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Bootstrap script for WSL Ubuntu development environment"
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

# ============================================================================
# Initial Setup
# ============================================================================

printf '\n'
printf '%s\n' "WSL Ubuntu Development Environment Setup"
printf '\n'

# WSL環境チェック
if [ "$SKIP_WSL_CHECK" = false ] && ! is_wsl; then
  log_warning "This script is optimized for WSL Ubuntu environment."
  if [ "$DRY_RUN" = true ] || [ "$CI_MODE" = true ]; then
    log_info "Skipping WSL check in CI/dry-run mode"
  else
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
fi

log_info "Environment: $(lsb_release -ds 2>/dev/null || cat /etc/*release | head -n1)"

# Ensure WSL interop is enabled for browser launch
if is_wsl; then
  if [ -f /etc/wsl.conf ]; then
    if grep -q '^\[interop\]' /etc/wsl.conf; then
      if grep -q '^\s*enabled\s*=\s*false' /etc/wsl.conf; then
        sudo sed -i 's/^\s*enabled\s*=\s*false/enabled = true/' /etc/wsl.conf
        log_info "Enabled WSL interop in /etc/wsl.conf"
      fi
    else
      sudo tee -a /etc/wsl.conf > /dev/null <<'EOF'

[interop]
enabled = true
appendWindowsPath = true
EOF
      log_info "Added WSL interop config to /etc/wsl.conf"
    fi
  fi
fi

# ============================================================================
# Setup Dotfiles Directory
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$DOTFILES_DIR" || exit 1
log_info "Using dotfiles at: $DOTFILES_DIR"

# Move dotfiles into ghq root if possible
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

# ============================================================================
# System Packages Update
# ============================================================================

if [ "$DRY_RUN" = true ]; then
  log_info "[DRY-RUN] Would update packages"
  log_info "[DRY-RUN] Would install system dependencies"
  log_success "Dry-run completed successfully"
  exit 0
fi

log_info "Updating packages..."
sudo env DEBIAN_FRONTEND=noninteractive apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

log_info "Installing system dependencies..."
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  git \
  unzip \
  build-essential \
  pkg-config \
  libssl-dev \
  g++ \
  lld \
  ca-certificates \
  gnupg \
  lsb-release \
  fish \
  wslu

# ============================================================================
# Mise (Polyglot Runtime Manager) Setup
# ============================================================================

log_info "Installing mise..."
if ! command -v mise &> /dev/null; then
  # Download and install mise without piping to avoid nested pipes
  MISE_INSTALL_SCRIPT=$(mktemp)
  TMP_FILES+=("$MISE_INSTALL_SCRIPT")
  curl -fsSL https://mise.run -o "$MISE_INSTALL_SCRIPT"
  sh "$MISE_INSTALL_SCRIPT"
  export PATH="$HOME/.local/bin:$PATH"
  # Don't use eval with command substitution in piped context
  if [ -f "$HOME/.local/bin/mise" ]; then
    "$HOME/.local/bin/mise" activate bash >> "$HOME/.bashrc.mise.tmp"
    TMP_FILES+=("$HOME/.bashrc.mise.tmp")
    if [ ! -f "$HOME/.bashrc" ]; then
      touch "$HOME/.bashrc"
    fi
    if ! grep -Fq "mise activate bash" "$HOME/.bashrc"; then
      cat "$HOME/.bashrc.mise.tmp" >> "$HOME/.bashrc"
    fi
  fi
  log_success "mise installed"
else
  log_success "mise already installed"
fi

# ============================================================================
# Create Symbolic Links
# ============================================================================

log_info "Creating symbolic links..."

# Bash configuration
if [ -f "$HOME/dotfiles/bash/bashrc" ]; then
  link_path "$HOME/dotfiles/bash/bashrc" "$HOME/.bashrc"
  log_success ".bashrc linked"
fi

# Mise configuration
if [ -f "$HOME/dotfiles/mise/mise.toml" ]; then
  link_path "$HOME/dotfiles/mise/mise.toml" "$HOME/.mise.toml"
  log_success "mise configuration linked"
fi

# Starship configuration
if [ -f "$HOME/dotfiles/starship/starship.toml" ]; then
  mkdir -p "$HOME/.config"
  link_path "$HOME/dotfiles/starship/starship.toml" "$HOME/.config/starship.toml"
  log_success "starship configuration linked"
fi

# Fish configuration
if [ -d "$HOME/dotfiles/fish" ]; then
  mkdir -p "$HOME/.config/fish"
  link_path "$HOME/dotfiles/fish/config.fish" "$HOME/.config/fish/config.fish"
  link_path "$HOME/dotfiles/fish/functions" "$HOME/.config/fish/functions"
  link_path "$HOME/dotfiles/fish/conf.d" "$HOME/.config/fish/conf.d"
  log_success "fish configuration linked"
fi

# Git configuration
if [ -f "$HOME/dotfiles/git/gitconfig" ]; then
  link_path "$HOME/dotfiles/git/gitconfig" "$HOME/.gitconfig"
  log_success "git configuration linked"
fi

if [ -f "$HOME/dotfiles/git/gitignore_global" ]; then
  link_path "$HOME/dotfiles/git/gitignore_global" "$HOME/.gitignore_global"
  log_success "global gitignore linked"
fi

# ============================================================================
# Install Development Tools via Mise
# ============================================================================

log_info "Installing tools via mise..."
if command -v mise &> /dev/null; then
  mise install
  log_success "All mise tools installed"
fi

# Source bashrc if it exists
if [ -f ~/.bashrc ]; then
  if [ "$CI_MODE" = true ]; then
    log_info "Skipping .bashrc sourcing in CI mode"
  else
    # shellcheck source=/dev/null
    source ~/.bashrc
  fi
fi

# ============================================================================
# Docker Setup for WSL2
# ============================================================================

log_info "Installing Docker..."
if [ "$CI_MODE" = true ]; then
  log_info "Skipping Docker install in CI mode"
elif ! command -v docker &> /dev/null; then
  # Docker公式GPGキーを追加
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Dockerリポジトリを設定
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Dockerをインストール
  sudo env DEBIAN_FRONTEND=noninteractive apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # ユーザーをdockerグループに追加
  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"
  log_success "Docker installed"
  log_warning "Please log out and back in for docker group membership to take effect"
else
  log_success "Docker already installed"
  # dockerグループへの追加を確認
  if ! groups "$USER" | grep -q '\bdocker\b'; then
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"
    log_success "Added user to docker group"
    log_warning "Please log out and back in for docker group membership to take effect"
  fi
fi

# ============================================================================
# VS Code Configuration
# ============================================================================

log_info "Applying VS Code settings..."

# VS Code のユーザー設定ディレクトリ
VSCODE_USER_DIR="$HOME/.config/Code/User"

# settings.json の反映
if [ -f "$HOME/dotfiles/.vscode/settings.json" ]; then
  mkdir -p "$VSCODE_USER_DIR"
  ln -sf "$HOME/dotfiles/.vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
  log_success "VS Code settings linked"
fi

# WSL環境でのVS Code拡張機能のインストール
if [ "$CI_MODE" = true ]; then
  log_info "Skipping VS Code extensions install in CI mode"
elif grep -qi microsoft /proc/version && [ -f "$HOME/dotfiles/.vscode/extensions.json" ]; then
  # VS Code Serverのcodeコマンドを探す
  CODE_CMD=""
  for cmd in $(type -a code 2>/dev/null | awk '{print $NF}' || true); do
    if [[ "$cmd" == *".vscode-server"* ]]; then
      CODE_CMD="$cmd"
      break
    fi
  done

  if [ -n "$CODE_CMD" ]; then
    log_info "Installing VS Code extensions..."
    INSTALLED_EXTENSIONS=$("$CODE_CMD" --list-extensions 2>/dev/null | tail -n +2 || true)

    jq -r '.recommendations[]' "$HOME/dotfiles/.vscode/extensions.json" 2>/dev/null | while read -r ext; do
      if echo "$INSTALLED_EXTENSIONS" | grep -qi "^${ext}$"; then
        echo "  Already installed: $ext"
      else
        echo "  Installing: $ext"
        "$CODE_CMD" --install-extension "$ext" --force 2>&1 | grep -v "^WSL:" || true
      fi
    done
    log_success "VS Code extensions configured"
  else
    log_warning "VS Code command not found in WSL. Please open VS Code from WSL once and re-run this script."
  fi
fi


# ============================================================================
# Fish Shell as Default
# ============================================================================

log_info "Setting up Fish shell as default..."

# Add fish to valid shells
FISH_PATH=$(command -v fish || true)
if [ -n "$FISH_PATH" ]; then
  if [ "$CI_MODE" = true ]; then
    log_info "Skipping default shell change in CI mode"
  elif ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    log_success "Fish added to valid shells"
  fi

  # Set fish as default shell
  if [ "$CI_MODE" = false ]; then
    chsh -s "$FISH_PATH"
    log_success "Fish set as default shell"
    SHELL_MSG="Fish is now your default shell. Please log out and back in to apply."
  fi
else
  log_error "Fish installation failed"
fi

# ============================================================================
# Final Steps
# ============================================================================

printf '\n'
printf '%s\n' "Setup Complete"
printf '\n'

# Display installed versions
log_info "Installed versions:"
if command -v mise &> /dev/null; then
  echo "  • mise: $(mise --version 2>/dev/null | head -n1)"
  mise list --current 2>/dev/null | head -n10
fi
[ -x "$(command -v docker)" ] && echo "  • Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
[ -x "$(command -v fish)" ] && echo "  • Fish: $(fish --version 2>&1 | cut -d' ' -f3)"

printf '\n'
log_info "Next steps:"
echo "  1. Log out and log back in to apply all changes"
[ -n "$SHELL_MSG" ] && echo "  2. $SHELL_MSG"
echo "  3. Verify installation: mise list"
echo "  4. Push dotfiles changes: git -C ~/dotfiles add -A && git -C ~/dotfiles commit -m \"Update dotfiles\" && git -C ~/dotfiles push"
printf '\n'

log_success "Happy coding!"
