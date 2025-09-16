#!/bin/bash
set -e

echo "🔧 Updating packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing common packages..."
sudo apt install -y curl git unzip build-essential pkg-config libssl-dev jq cmake clang g++ lld

echo "🔧 Installing GitHub CLI (gh)..."
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

echo "🔧 Installing Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

echo "🔧 Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
echo "source \"\$HOME/.cargo/env\"" >> ~/.bashrc
source "$HOME/.cargo/env"

echo "✅ Installation complete! Please run 'exec \$SHELL' or restart your terminal to apply changes."
