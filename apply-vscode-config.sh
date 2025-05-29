#!/bin/bash
set -e

echo "🧩 Applying VS Code settings and extensions..."

# VS Code のユーザー設定ディレクトリ
VSCODE_USER_DIR="$HOME/.config/Code/User"

# settings.json の反映
echo "🔧 Copying settings.json..."
mkdir -p "$VSCODE_USER_DIR"
cp -v "./.vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

# 拡張機能のインストール
echo "📦 Installing recommended extensions..."
jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
  echo "➡️  Installing extension: $ext"
  code --install-extension "$ext" --force
done

echo "✅ VS Code configuration applied successfully!"
