#!/bin/bash
set -e

# WSL Ubuntu環境用のセットアップスクリプト

# WSL環境チェック
if ! grep -qi microsoft /proc/version; then
  echo "⚠️  Warning: This script is optimized for WSL Ubuntu environment."
  read -p "Continue anyway? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo "🐧 Starting WSL Ubuntu setup..."
echo "📍 Environment: $(lsb_release -ds 2>/dev/null || cat /etc/*release | head -n1)"

echo "🔧 Updating packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing essential packages..."
sudo apt install -y \
  curl \
  git \
  unzip \
  build-essential \
  pkg-config \
  libssl-dev \
  jq \
  cmake \
  clang \
  g++ \
  lld \
  vim \
  htop \
  tree \
  ca-certificates \
  gnupg \
  lsb-release

echo "🔧 Installing mise (polyglot runtime manager)..."
if ! command -v mise &> /dev/null; then
  curl https://mise.run | sh

  # Bashにmiseの設定を追加
  if ! grep -q 'mise activate' ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo '# mise' >> ~/.bashrc
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
  fi

  # 現在のセッションでmiseを有効化
  export PATH="$HOME/.local/bin:$PATH"
  eval "$(~/.local/bin/mise activate bash)"

  echo "  ✓ mise installed successfully"
else
  echo "  ✓ mise already installed"
fi

echo "📦 Installing tools via mise..."
# mise設定ファイルをシンボリックリンクでホームディレクトリに配置
if [ -f "$HOME/dotfiles/.mise.toml" ]; then
  # 既存のファイルやリンクがあれば削除
  if [ -e "$HOME/.mise.toml" ] || [ -L "$HOME/.mise.toml" ]; then
    rm -f "$HOME/.mise.toml"
  fi
  ln -s "$HOME/dotfiles/.mise.toml" "$HOME/.mise.toml"
  echo "  ✓ mise configuration linked"
fi

# miseで.mise.tomlに定義されたツールを一括インストール
if command -v mise &> /dev/null; then
  echo "  Installing tools defined in .mise.toml..."
  mise install
  echo "  ✓ All mise tools installed"
fi

echo "🔧 Installing Docker..."
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

  # ユーザーをdockerグループに追加（sudo不要化）
  sudo groupadd -f docker
  sudo usermod -aG docker $USER
  echo "  ✓ Docker installed"
  echo "  ⚠️  Please log out and back in for docker group membership to take effect"
else
  echo "  ✓ Docker already installed"
  # dockerグループへの追加を確認
  if ! groups $USER | grep -q '\bdocker\b'; then
    sudo groupadd -f docker
    sudo usermod -aG docker $USER
    echo "  ✓ Added user to docker group"
    echo "  ⚠️  Please log out and back in for docker group membership to take effect"
  fi
fi

# WSL2でDockerデーモンを自動起動する設定
if grep -qi microsoft /proc/version; then
  if ! grep -q "sudo service docker start" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Auto-start Docker daemon in WSL2" >> ~/.bashrc
    echo "if ! service docker status > /dev/null 2>&1; then" >> ~/.bashrc
    echo "    sudo service docker start > /dev/null 2>&1" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
    echo "  ✓ Configured Docker auto-start for WSL2"
  fi
fi

# グローバルnpmパッケージの更新（miseでNode.jsがインストールされている場合）
echo "📦 Installing global npm packages..."
if command -v npm &> /dev/null; then
  # よく使うnpmツールをインストール
  echo "  Installing useful npm tools..."

  # npm-check-updates - package.jsonの依存関係更新チェック
  if ! npm list -g npm-check-updates --depth=0 &> /dev/null; then
    npm install -g npm-check-updates
    echo "    ✓ npm-check-updates installed"
  fi

  # prettier - コードフォーマッター
  if ! npm list -g prettier --depth=0 &> /dev/null; then
    npm install -g prettier
    echo "    ✓ prettier installed"
  fi

  # typescript - TypeScript
  if ! npm list -g typescript --depth=0 &> /dev/null; then
    npm install -g typescript
    echo "    ✓ typescript installed"
  fi
fi

# WSL特有の設定
echo "🔧 Configuring WSL-specific settings..."

# Windows側のホームディレクトリへのリンク作成（存在しない場合のみ）
if [ -d "/mnt/c/Users" ] && [ ! -L "$HOME/winhome" ]; then
  WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
  if [ -n "$WIN_USER" ] && [ -d "/mnt/c/Users/$WIN_USER" ]; then
    ln -s "/mnt/c/Users/$WIN_USER" "$HOME/winhome"
    echo "  ✓ Created symlink to Windows home directory"
  fi
fi

# Git credential helperをWindows側と共有
if command -v git &> /dev/null; then
  git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
  echo "  ✓ Configured Git credential helper for Windows integration"
fi

echo "✅ WSL Ubuntu setup complete!"
echo "📋 Please restart your terminal or run: source ~/.bashrc"
echo ""
echo "📊 Installed versions:"
if command -v mise &> /dev/null; then
  echo "  • mise: $(mise --version 2>/dev/null | head -n1)"
  mise list --current 2>/dev/null | head -n10
fi
[ -x "$(command -v docker)" ] && echo "  • Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"