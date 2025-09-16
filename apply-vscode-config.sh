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

# WSL環境でのVS Code確認と適切なコマンドの選択
CODE_CMD=""

# WSL環境でWindows側のVS Codeを使用する場合
if grep -qi microsoft /proc/version; then
  # WSL用のcode.cmdまたはcode.exeを探す
  if [ -f "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin/code.cmd" ]; then
    CODE_CMD="/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft\ VS\ Code/bin/code.cmd"
  elif [ -f "/mnt/c/Program Files/Microsoft VS Code/bin/code.cmd" ]; then
    CODE_CMD="/mnt/c/Program\ Files/Microsoft\ VS\ Code/bin/code.cmd"
  fi

  # PowerShell経由でWindows側のVS Codeを実行
  if [ -n "$CODE_CMD" ] && command -v powershell.exe &> /dev/null; then
    jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
      echo "➡️  Installing extension: $ext"
      powershell.exe -Command "code --install-extension '$ext' --force" 2>/dev/null || true
    done
  else
    echo "⚠️  VS Code not found or cannot execute from WSL."
    echo "📌 Please install extensions manually from VS Code:"
    jq -r '.recommendations[]' .vscode/extensions.json | while read -r ext; do
      echo "  - $ext"
    done
    echo ""
    echo "💡 Tip: Open VS Code from WSL using 'code .' and install extensions from the Extensions panel."
  fi
elif command -v code &> /dev/null; then
  # Native Linux環境
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
