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
  tree

echo "🔧 Installing Docker..."
if ! command -v docker &> /dev/null; then
  # Dockerの公式インストール手順
  echo "  Installing Docker prerequisites..."
  sudo apt install -y \
    ca-certificates \
    gnupg \
    lsb-release

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

echo "🔧 Installing GitHub CLI (gh)..."
if ! command -v gh &> /dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh -y
else
  echo "  ✓ GitHub CLI already installed"
fi

echo "🔧 Installing/Updating Node.js to latest LTS..."
# Node.js の最新LTSバージョンを取得
LATEST_NODE_LTS=$(curl -sL https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)] | first | .version' | cut -d'v' -f2)
LATEST_NODE_MAJOR=$(echo "$LATEST_NODE_LTS" | cut -d'.' -f1)

if ! command -v node &> /dev/null; then
  echo "  Installing Node.js $LATEST_NODE_MAJOR.x (LTS)..."
  curl -fsSL "https://deb.nodesource.com/setup_${LATEST_NODE_MAJOR}.x" | sudo -E bash -
  sudo apt install -y nodejs
elif [ "$(node --version | cut -d'v' -f2 | cut -d'.' -f1)" -lt "$LATEST_NODE_MAJOR" ]; then
  echo "  Updating Node.js from $(node --version) to $LATEST_NODE_MAJOR.x (LTS)..."
  curl -fsSL "https://deb.nodesource.com/setup_${LATEST_NODE_MAJOR}.x" | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "  ✓ Node.js $(node --version) already installed (LTS: $LATEST_NODE_MAJOR.x)"
fi

echo "🔧 Updating npm to latest version..."
if command -v npm &> /dev/null; then
  CURRENT_NPM=$(npm --version)
  sudo npm install -g npm@latest
  NEW_NPM=$(npm --version)
  if [ "$CURRENT_NPM" != "$NEW_NPM" ]; then
    echo "  ✓ npm updated from $CURRENT_NPM to $NEW_NPM"
  else
    echo "  ✓ npm $NEW_NPM is already the latest version"
  fi
else
  echo "  ⚠️  npm not found, will be installed with Node.js"
fi

echo "🔧 Installing/Updating Rust..."
if ! command -v cargo &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

  # Bashにのみ設定を追加
  if ! grep -q ".cargo/env" ~/.bashrc; then
    echo "source \"\$HOME/.cargo/env\"" >> ~/.bashrc
  fi
  source "$HOME/.cargo/env"
  echo "  ✓ Rust installed successfully"
else
  echo "  Updating Rust toolchain..."
  source "$HOME/.cargo/env"
  rustup update stable
  echo "  ✓ Rust $(rustc --version | cut -d' ' -f2) installed"
fi

# よく使うRustツールをインストール
echo "📦 Installing useful Rust tools..."
if command -v cargo &> /dev/null; then
  # ripgrep - 高速grep
  if ! command -v rg &> /dev/null; then
    cargo install ripgrep
    echo "  ✓ ripgrep installed"
  fi

  # fd - 高速find
  if ! command -v fd &> /dev/null; then
    cargo install fd-find
    echo "  ✓ fd installed"
  fi

  # bat - catの代替（シンタックスハイライト付き）
  if ! command -v bat &> /dev/null; then
    cargo install bat
    echo "  ✓ bat installed"
  fi

  # exa - lsの代替（モダンな表示）
  if ! command -v eza &> /dev/null; then
    cargo install eza
    echo "  ✓ eza installed"
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

# グローバルnpmパッケージの更新
echo "📦 Updating global npm packages..."
if command -v npm &> /dev/null; then
  # 古いnpmパッケージのチェック
  OUTDATED=$(npm outdated -g --depth=0 2>/dev/null | tail -n +2)
  if [ -n "$OUTDATED" ]; then
    echo "  Updating outdated global packages..."
    sudo npm update -g
    echo "  ✓ Global npm packages updated"
  else
    echo "  ✓ All global npm packages are up to date"
  fi

  # よく使うnpmツールをインストール
  echo "  Installing useful npm tools..."

  # npm-check-updates - package.jsonの依存関係更新チェック
  if ! npm list -g npm-check-updates --depth=0 &> /dev/null; then
    sudo npm install -g npm-check-updates
    echo "    ✓ npm-check-updates installed"
  fi

  # prettier - コードフォーマッター
  if ! npm list -g prettier --depth=0 &> /dev/null; then
    sudo npm install -g prettier
    echo "    ✓ prettier installed"
  fi

  # typescript - TypeScript
  if ! npm list -g typescript --depth=0 &> /dev/null; then
    sudo npm install -g typescript
    echo "    ✓ typescript installed"
  fi
fi

echo "✅ WSL Ubuntu setup complete!"
echo "📋 Please restart your terminal or run: source ~/.bashrc"
echo ""
echo "📊 Installed versions:"
[ -x "$(command -v node)" ] && echo "  • Node.js: $(node --version)"
[ -x "$(command -v npm)" ] && echo "  • npm: $(npm --version)"
[ -x "$(command -v rustc)" ] && echo "  • Rust: $(rustc --version | cut -d' ' -f2)"
[ -x "$(command -v gh)" ] && echo "  • GitHub CLI: $(gh --version | head -n1 | cut -d' ' -f3)"
[ -x "$(command -v docker)" ] && echo "  • Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
