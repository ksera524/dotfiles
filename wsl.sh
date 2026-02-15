#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

parse_args "$@"
setup_tmp_cleanup

SHELL_MSG=""

printf '\n'
printf '%s\n' "WSL Ubuntu Development Environment Setup"
printf '\n'

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

if [ "$DRY_RUN" = true ]; then
  log_info "[DRY-RUN] Would configure WSL interop"
  log_info "[DRY-RUN] Would update packages"
  log_info "[DRY-RUN] Would install system dependencies"
  log_info "[DRY-RUN] Would install mise and link dotfiles"
  log_info "[DRY-RUN] Would install mise tools"
  log_info "[DRY-RUN] Would configure Docker and VS Code settings"
  log_info "[DRY-RUN] Would set fish as default shell"
  log_success "Dry-run completed successfully"
  exit 0
fi

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

setup_dotfiles_dir "$SCRIPT_DIR"

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

log_info "Installing mise..."
if ! command -v mise &> /dev/null; then
  MISE_INSTALL_SCRIPT=$(mktemp)
  register_tmp "$MISE_INSTALL_SCRIPT"
  curl -fsSL https://mise.run -o "$MISE_INSTALL_SCRIPT"
  sh "$MISE_INSTALL_SCRIPT"
  export PATH="$HOME/.local/bin:$PATH"
  if [ -f "$HOME/.local/bin/mise" ]; then
    "$HOME/.local/bin/mise" activate bash >> "$HOME/.bashrc.mise.tmp"
    register_tmp "$HOME/.bashrc.mise.tmp"
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

log_info "Creating symbolic links..."

if [ -f "$HOME/dotfiles/bash/bashrc" ]; then
  link_path "$HOME/dotfiles/bash/bashrc" "$HOME/.bashrc"
  log_success ".bashrc linked"
fi

if [ -f "$HOME/dotfiles/mise/mise.toml" ]; then
  link_path "$HOME/dotfiles/mise/mise.toml" "$HOME/.mise.toml"
  log_success "mise configuration linked"
fi

if [ -f "$HOME/dotfiles/starship/starship.toml" ]; then
  mkdir -p "$HOME/.config"
  link_path "$HOME/dotfiles/starship/starship.toml" "$HOME/.config/starship.toml"
  log_success "starship configuration linked"
fi

if [ -d "$HOME/dotfiles/fish" ]; then
  mkdir -p "$HOME/.config/fish"
  link_path "$HOME/dotfiles/fish/config.fish" "$HOME/.config/fish/config.fish"
  link_path "$HOME/dotfiles/fish/functions" "$HOME/.config/fish/functions"
  link_path "$HOME/dotfiles/fish/conf.d" "$HOME/.config/fish/conf.d"
  log_success "fish configuration linked"
fi

if [ -f "$HOME/dotfiles/git/gitconfig" ]; then
  link_path "$HOME/dotfiles/git/gitconfig" "$HOME/.gitconfig"
  log_success "git configuration linked"
fi

if [ -f "$HOME/dotfiles/git/gitignore_global" ]; then
  link_path "$HOME/dotfiles/git/gitignore_global" "$HOME/.gitignore_global"
  log_success "global gitignore linked"
fi

log_info "Installing tools via mise..."
if command -v mise &> /dev/null; then
  mise install
  log_success "All mise tools installed"
fi

if [ -f ~/.bashrc ]; then
  if [ "$CI_MODE" = true ]; then
    log_info "Skipping .bashrc sourcing in CI mode"
  else
    # shellcheck source=/dev/null
    source ~/.bashrc
  fi
fi

log_info "Installing Docker..."
if [ "$CI_MODE" = true ]; then
  log_info "Skipping Docker install in CI mode"
elif ! command -v docker &> /dev/null; then
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo env DEBIAN_FRONTEND=noninteractive apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"
  log_success "Docker installed"
  log_warning "Please log out and back in for docker group membership to take effect"
else
  log_success "Docker already installed"
  if ! groups "$USER" | grep -q '\bdocker\b'; then
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"
    log_success "Added user to docker group"
    log_warning "Please log out and back in for docker group membership to take effect"
  fi
fi

log_info "Applying VS Code settings..."

VSCODE_USER_DIR="$HOME/.config/Code/User"

if [ -f "$HOME/dotfiles/.vscode/settings.json" ]; then
  mkdir -p "$VSCODE_USER_DIR"
  ln -sf "$HOME/dotfiles/.vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
  log_success "VS Code settings linked"
fi

if [ "$CI_MODE" = true ]; then
  log_info "Skipping VS Code extensions install in CI mode"
elif is_wsl && [ -f "$HOME/dotfiles/.vscode/extensions.json" ]; then
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

log_info "Setting up Fish shell as default..."

FISH_PATH=$(command -v fish || true)
if [ -n "$FISH_PATH" ]; then
  if [ "$CI_MODE" = true ]; then
    log_info "Skipping default shell change in CI mode"
  elif ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    log_success "Fish added to valid shells"
  fi

  if [ "$CI_MODE" = false ]; then
    chsh -s "$FISH_PATH"
    log_success "Fish set as default shell"
    SHELL_MSG="Fish is now your default shell. Please log out and back in to apply."
  fi
else
  log_error "Fish installation failed"
fi

printf '\n'
printf '%s\n' "Setup Complete"
printf '\n'

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
