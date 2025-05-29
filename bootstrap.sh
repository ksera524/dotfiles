#!/bin/bash
set -e

echo "🌐 Cloning dotfiles..."
cd ~
rm -rf dotfiles
git clone https://github.com/ksera524/dotfiles.git

cd ~/dotfiles

echo "🔧 Running install.sh..."
bash install.sh

echo "🧩 Applying VSCode config..."
bash apply-vscode-config.sh

echo "🔧 Setting up Git config..."
bash setup-git.sh

echo "✅ All setup complete!"
