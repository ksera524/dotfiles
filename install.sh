#!/usr/bin/env bash
set -euo pipefail

main() {
  if [ "$EUID" -eq 0 ]; then
    printf 'Run this installer as a normal user, without sudo.\n' >&2
    return 1
  fi

  case "$(uname -s)" in
    Linux) ;;
    Darwin)
      if ! xcode-select -p >/dev/null 2>&1; then
        printf 'Install Xcode Command Line Tools first: xcode-select --install\n' >&2
        return 1
      fi
      if [ "$(uname -m)" = x86_64 ] && ! command -v brew >/dev/null 2>&1; then
        printf 'Intel Macs require Homebrew first: https://brew.sh/\n' >&2
        return 1
      fi
      ;;
    *)
      printf 'Supported platforms: Ubuntu (WSL) and macOS.\n' >&2
      return 1
      ;;
  esac

  # Use the official installer; it keeps an existing same-or-newer release.
  curl -fsSL https://mise.run | MISE_VERSION=v2026.10.8 sh
  local mise_bin="$HOME/.local/bin/mise"
  export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

  local dotfiles_root repo_dir
  dotfiles_root="${DOTFILES_ROOT:-$(git config --path --get ghq.root 2>/dev/null || printf '%s' "$HOME/src")}"
  mkdir -p "$dotfiles_root"
  dotfiles_root="$(cd "$dotfiles_root" && pwd -P)"
  repo_dir="$dotfiles_root/github.com/ksera524/dotfiles"
  export DOTFILES_ROOT="$dotfiles_root"

  # mise installs missing Git, validates/reuses the checkout, and trusts it.
  "$mise_bin" bootstrap \
    --from https://github.com/ksera524/dotfiles.git \
    --from-dir "$repo_dir" --yes --update
}

# Parse the entire function before commands run, including when piped into Bash.
main "$@"
