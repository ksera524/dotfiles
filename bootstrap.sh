#!/bin/bash
set -e

echo "🌐 Cloning dotfiles..."
cd ~
rm -rf dotfiles
git clone https://github.com/ksera524/dotfiles.git

cd ~/dotfiles

echo "🔧 Running install.sh (with mise setup)..."
bash install.sh

# miseを現在のセッションで有効化し、インストール状況を確認
if [ -f "$HOME/.local/bin/mise" ]; then
  export PATH="$HOME/.local/bin:$PATH"
  eval "$(~/.local/bin/mise activate bash)"
  echo "✓ mise activated for current session"

  # インストールされたツールを表示
  echo ""
  echo "📊 Installed tools:"
  mise list --current
fi

echo "🧩 Applying VSCode config..."
bash apply-vscode-config.sh

echo "🔧 Setting up Git config..."
bash setup-git.sh

echo "✅ All setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Restart your terminal or run: source ~/.bashrc"
echo "   2. Verify installation: mise list"
echo "   3. Update tools anytime: ./update-tools.sh"
