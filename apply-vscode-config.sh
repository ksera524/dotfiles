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
if command -v code &> /dev/null; then
  jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
    echo "➡️  Installing extension: $ext"
    code --install-extension "$ext" --force
  done
else
  echo "⚠️  VS Code command not found. Please install extensions manually:"
  jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
    echo "  - $ext"
  done
fi

echo "✅ VS Code configuration applied successfully!"
