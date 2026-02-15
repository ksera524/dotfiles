#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

parse_args "$@"
setup_tmp_cleanup

SHELL_MSG=""

printf '\n'
printf '%s\n' "macOS Development Environment Setup"
printf '\n'

if ! is_macos; then
  log_error "macOS not detected"
  exit 1
fi

if ! xcode-select -p &> /dev/null; then
  log_warning "Xcode Command Line Tools not found"
  log_info "Run: xcode-select --install"
  exit 1
fi

log_info "Environment: $(sw_vers -productName) $(sw_vers -productVersion)"

if [ "$DRY_RUN" = true ]; then
  log_info "[DRY-RUN] Would install mise"
  log_info "[DRY-RUN] Would link dotfiles"
  log_info "[DRY-RUN] Would install mise tools"
  log_info "[DRY-RUN] Would verify fish and Docker availability"
  log_success "Dry-run completed successfully"
  exit 0
fi

setup_dotfiles_dir "$SCRIPT_DIR"

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

log_info "Checking Docker..."
if command -v docker &> /dev/null; then
  log_success "Docker is available"
else
  log_warning "Docker not found. Install Docker Desktop for macOS."
fi

log_info "Applying VS Code settings..."

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

if [ -f "$HOME/dotfiles/.vscode/settings.json" ]; then
  mkdir -p "$VSCODE_USER_DIR"
  ln -sf "$HOME/dotfiles/.vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
  log_success "VS Code settings linked"
fi

if command -v fish &> /dev/null; then
  log_info "Fish shell detected"
else
  log_warning "Fish not found. Install fish manually if needed."
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
echo "  1. Verify installation: mise list"
echo "  2. Install Docker Desktop if you need containers"
echo "  3. Install fish if you want to use it as default shell"
echo "  4. Push dotfiles changes: git -C ~/dotfiles add -A && git -C ~/dotfiles commit -m \"Update dotfiles\" && git -C ~/dotfiles push"
printf '\n'

log_success "Happy coding!"
