#!/bin/bash
set -e

# ============================================================================
# Bootstrap Script for WSL Ubuntu Environment
# One-shot setup for development environment with mise, fish, docker, etc.
# ============================================================================

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# ============================================================================
# Initial Setup
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🚀 WSL Ubuntu Development Environment Setup            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# WSL環境チェック
if ! grep -qi microsoft /proc/version; then
  log_warning "This script is optimized for WSL Ubuntu environment."
  read -p "Continue anyway? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

log_info "Environment: $(lsb_release -ds 2>/dev/null || cat /etc/*release | head -n1)"

# ============================================================================
# Clone or Update Dotfiles Repository
# ============================================================================

# Check if script is being piped from curl/wget or run locally
# When piped, $0 is typically "bash" or "sh", and BASH_SOURCE is empty or equals $0
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "$0" ] && { [ "$0" = "bash" ] || [ "$0" = "sh" ] || [ "$0" = "-bash" ] || [ -z "$0" ]; }; then
  # Script is being run via curl | bash
  log_info "Running from curl/wget. Cloning dotfiles repository..."
  cd ~
  if [ -d dotfiles ]; then
    log_info "Dotfiles directory exists. Updating..."
    cd dotfiles
    git pull origin main
  else
    git clone https://github.com/ksera524/dotfiles.git
    cd dotfiles
  fi

  # Re-execute the script from the cloned repository
  log_info "Re-executing bootstrap.sh from cloned repository..."
  exec bash ./bootstrap.sh "$@"
  exit $?
else
  # Script is being run locally
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  cd "$DOTFILES_DIR"
  log_info "Using local dotfiles at: $DOTFILES_DIR"
fi

# ============================================================================
# System Packages Update
# ============================================================================

log_info "Updating packages..."
sudo apt update && sudo apt upgrade -y

log_info "Installing system dependencies..."
sudo apt install -y \
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
  jq

# ============================================================================
# Mise (Polyglot Runtime Manager) Setup
# ============================================================================

log_info "Installing mise..."
if ! command -v mise &> /dev/null; then
  # Download and install mise without piping to avoid nested pipes
  MISE_INSTALL_SCRIPT=$(mktemp)
  curl -fsSL https://mise.run -o "$MISE_INSTALL_SCRIPT"
  sh "$MISE_INSTALL_SCRIPT"
  rm -f "$MISE_INSTALL_SCRIPT"
  export PATH="$HOME/.local/bin:$PATH"
  # Don't use eval with command substitution in piped context
  if [ -f "$HOME/.local/bin/mise" ]; then
    "$HOME/.local/bin/mise" activate bash >> "$HOME/.bashrc.mise.tmp"
    cat "$HOME/.bashrc.mise.tmp" >> "$HOME/.bashrc"
    rm -f "$HOME/.bashrc.mise.tmp"
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
  ln -sf "$HOME/dotfiles/bash/bashrc" "$HOME/.bashrc"
  log_success ".bashrc linked"
fi

# Mise configuration
if [ -f "$HOME/dotfiles/mise/mise.toml" ]; then
  ln -sf "$HOME/dotfiles/mise/mise.toml" "$HOME/.mise.toml"
  log_success "mise configuration linked"
fi

# Starship configuration
if [ -f "$HOME/dotfiles/starship/starship.toml" ]; then
  mkdir -p "$HOME/.config"
  ln -sf "$HOME/dotfiles/starship/starship.toml" "$HOME/.config/starship.toml"
  log_success "starship configuration linked"
fi

# Fish configuration
if [ -d "$HOME/dotfiles/fish" ]; then
  mkdir -p "$HOME/.config/fish"
  if [ -f "$HOME/.config/fish/config.fish" ] && [ ! -L "$HOME/.config/fish/config.fish" ]; then
    mv "$HOME/.config/fish/config.fish" "$HOME/.config/fish/config.fish.backup"
  fi
  ln -sf "$HOME/dotfiles/fish/config.fish" "$HOME/.config/fish/config.fish"

  # Remove existing directories/links before creating symlinks
  [ -e "$HOME/.config/fish/functions" ] && rm -rf "$HOME/.config/fish/functions"
  [ -e "$HOME/.config/fish/conf.d" ] && rm -rf "$HOME/.config/fish/conf.d"

  ln -sf "$HOME/dotfiles/fish/functions" "$HOME/.config/fish/functions"
  ln -sf "$HOME/dotfiles/fish/conf.d" "$HOME/.config/fish/conf.d"
  log_success "fish configuration linked"
fi

# Git configuration
if [ -f "$HOME/dotfiles/git/gitconfig" ]; then
  ln -sf "$HOME/dotfiles/git/gitconfig" "$HOME/.gitconfig"
  log_success "git configuration linked"
fi

if [ -f "$HOME/dotfiles/git/gitignore_global" ]; then
  ln -sf "$HOME/dotfiles/git/gitignore_global" "$HOME/.gitignore_global"
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

# Only source bashrc if we're in an interactive shell, not when piped
if [ -t 0 ] && [ -f ~/.bashrc ]; then
  # shellcheck source=/dev/null
  source ~/.bashrc
fi

# ============================================================================
# Docker Setup for WSL2
# ============================================================================

log_info "Installing Docker..."
if ! command -v docker &> /dev/null; then
  # Docker公式GPGキーを追加
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  # Dockerリポジトリを設定
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Dockerをインストール
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
if grep -qi microsoft /proc/version && [ -f "$HOME/dotfiles/.vscode/extensions.json" ]; then
  # VS Code Serverのcodeコマンドを探す
  CODE_CMD=""
  for cmd in $(type -a code 2>/dev/null | awk '{print $NF}'); do
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
        echo "  ✓ Already installed: $ext"
      else
        echo "  ➡️  Installing: $ext"
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
FISH_PATH=$(which fish)
if [ -n "$FISH_PATH" ]; then
  if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    log_success "Fish added to valid shells"
  fi

  # Set fish as default shell
  chsh -s "$FISH_PATH"
  log_success "Fish set as default shell"
  SHELL_MSG="🐠 Fish is now your default shell. Please log out and back in to apply."
else
  log_error "Fish installation failed"
  SHELL_MSG=""
fi

# ============================================================================
# Final Steps
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  ✨ Setup Complete! ✨                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Display installed versions
log_info "Installed versions:"
if command -v mise &> /dev/null; then
  echo "  • mise: $(mise --version 2>/dev/null | head -n1)"
  mise list --current 2>/dev/null | head -n10
fi
[ -x "$(command -v docker)" ] && echo "  • Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
[ -x "$(command -v fish)" ] && echo "  • Fish: $(fish --version 2>&1 | cut -d' ' -f3)"

echo ""
log_info "Next steps:"
echo "  1. Log out and log back in to apply all changes"
[ -n "$SHELL_MSG" ] && echo "  2. $SHELL_MSG"
echo "  3. Verify installation: mise list"
echo "  4. Push dotfiles changes: dotpush \"your message\""
echo ""

# Function definitions for current session
if [ -n "$BASH_VERSION" ]; then
  cat << 'EOF' >> /tmp/dotfiles_functions.sh
# Dotfiles management function
dotpush() {
    local current_dir=$(pwd)
    cd ~/dotfiles
    git add -A
    if [ -n "$1" ]; then
        git commit -m "$1"
    else
        git commit -m "Update dotfiles"
    fi
    git push
    cd "$current_dir"
}
EOF
  source /tmp/dotfiles_functions.sh
  rm /tmp/dotfiles_functions.sh
  log_info "dotpush function available in current session"
fi

log_success "Happy coding! 🎉"