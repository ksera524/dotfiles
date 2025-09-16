#!/bin/bash
set -e

echo "🧩 Applying VS Code settings and extensions..."

# VS Code のユーザー設定ディレクトリ
VSCODE_USER_DIR="$HOME/.config/Code/User"

# settings.json の反映
echo "🔧 Linking settings.json..."
mkdir -p "$VSCODE_USER_DIR"
# 既存のファイルやリンクがあれば削除
if [ -e "$VSCODE_USER_DIR/settings.json" ] || [ -L "$VSCODE_USER_DIR/settings.json" ]; then
  rm -f "$VSCODE_USER_DIR/settings.json"
fi
ln -sv "$HOME/dotfiles/.vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

# 拡張機能のインストール
echo "📦 Installing recommended extensions..."

# WSL環境でのVS Code確認
if grep -qi microsoft /proc/version; then
  echo "🐧 Detected WSL environment"

  # WSL環境では code コマンドが利用可能（VS Code Server経由）
  if command -v code &> /dev/null; then
    echo "✓ VS Code command found in WSL"

    # 現在インストールされている拡張機能を取得
    INSTALLED_EXTENSIONS=$(code --list-extensions 2>/dev/null | grep -v "^WSL:" | grep -v "にインストールされている拡張機能" || true)

    # 推奨拡張機能をインストール
    jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
      # 既にインストール済みかチェック
      if echo "$INSTALLED_EXTENSIONS" | grep -qi "^${ext}$"; then
        echo "✓ Already installed: $ext"
      else
        echo "➡️  Installing extension: $ext"
        code --install-extension "$ext" --force 2>/dev/null || echo "  ⚠️  Failed to install: $ext"
      fi
    done
  else
    echo "⚠️  VS Code command not found in WSL."
    echo "📌 Please ensure VS Code is opened from WSL at least once using 'code .'"
    echo "📌 Then run this script again."
    echo ""
    echo "📋 Extensions to be installed:"
    jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
      echo "  - $ext"
    done
  fi
elif command -v code &> /dev/null; then
  # Native Linux環境
  echo "🐧 Detected native Linux environment"

  # 現在インストールされている拡張機能を取得
  INSTALLED_EXTENSIONS=$(code --list-extensions 2>/dev/null || true)

  jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
    # 既にインストール済みかチェック
    if echo "$INSTALLED_EXTENSIONS" | grep -qi "^${ext}$"; then
      echo "✓ Already installed: $ext"
    else
      echo "➡️  Installing extension: $ext"
      code --install-extension "$ext" --force 2>/dev/null || echo "  ⚠️  Failed to install: $ext"
    fi
  done
else
  echo "⚠️  VS Code command not found. Please install extensions manually:"
  jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
    echo "  - $ext"
  done
fi

echo "✅ VS Code configuration applied successfully!"
