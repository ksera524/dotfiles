#!/bin/bash
set -e

echo "🔧 Updating mise tools..."

# miseがインストールされているか確認
if ! command -v mise &> /dev/null; then
  echo "❌ mise is not installed. Please run install.sh first."
  exit 1
fi

# .mise.tomlに定義されたツールを最新版に更新
echo "📦 Updating tools to latest versions..."
mise upgrade --all

echo ""
echo "📊 Currently installed tools:"
mise list --current