#!/bin/bash
set -e

echo "🌐 Cloning dotfiles..."
cd ~
rm -rf dotfiles
git clone https://github.com/ksera524/dotfiles.git

cd ~/dotfiles

echo "🔧 Running install.sh (with mise setup)..."
bash install.sh

# Docker installation for WSL2
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
  echo "  Installing Docker and Docker Compose..."
  sudo apt update
  sudo apt install -y docker.io docker-compose

  # Add current user to docker group
  echo "  Adding user to docker group..."
  sudo usermod -aG docker $USER

  # Start Docker service
  echo "  Starting Docker service..."
  sudo service docker start

  echo "  ✓ Docker installed successfully"
  echo "  ⚠️  Note: You may need to log out and back in for docker group changes to take effect"
else
  echo "  ✓ Docker is already installed"
  # Ensure Docker service is running
  if ! sudo service docker status > /dev/null 2>&1; then
    sudo service docker start
  fi
fi

# miseを現在のセッションで有効化し、インストール状況を確認
if [ -f "$HOME/.local/bin/mise" ]; then
  export PATH="$HOME/.local/bin:$PATH"
  eval "$(~/.local/bin/mise activate bash)"
  echo "✓ mise activated for current session"

  # mise設定ファイルのシンボリックリンクを作成
  echo "🔗 Creating mise config symlink..."
  mkdir -p ~/.config/mise
  ln -sf ~/.mise.toml ~/.config/mise/config.toml
  echo "✓ Symlink created: ~/.config/mise/config.toml -> ~/.mise.toml"

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
