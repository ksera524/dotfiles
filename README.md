# Dotfiles

WSL Ubuntu環境向けの開発環境セットアップスクリプトです。

## 🚀 Quick Start

### ワンコマンドでの完全セットアップ

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ksera524/dotfiles/main/bootstrap.sh)
```

または、リポジトリをクローン後：

```bash
git clone https://github.com/ksera524/dotfiles.git
cd dotfiles
./bootstrap.sh
```

## 📦 What's Included

`bootstrap.sh`は以下のすべてをセットアップします：

- **🔧 開発ツール管理**: [mise](https://mise.jdx.dev/)による統一的なツール管理
- **🐠 Fish Shell**: モダンなシェル環境とカスタム設定
- **⭐ Starship**: クロスシェル対応のプロンプト
- **🐳 Docker & Docker Compose**: コンテナ開発環境
- **📝 VS Code**: 設定と拡張機能の自動セットアップ
- **🔄 Git**: ユーザー設定とエイリアス

### インストールされるツール

- **言語**: Node.js (LTS), Rust (stable), Python 3.12
- **CLI**: GitHub CLI, ripgrep, fd, bat, eza, jq, bottom
- **開発**: TypeScript, Claude Code CLI
- **コンテナ**: Docker CE, Docker Compose

## 📚 Usage

### Dotfilesの更新をpush

どこからでもdotfilesの変更をGitHubにpushできます：

```bash
# デフォルトメッセージでpush
dotpush

# カスタムメッセージでpush
dotpush "Add new aliases"
```

### miseでツール管理

```bash
# インストール済みツールの確認
mise list

# すべてのツールを更新
mise upgrade --all

# 特定のツールを更新
mise upgrade node
```

## 🔧 Configuration Files

### ディレクトリ構造

```
dotfiles/
├── bootstrap.sh        # ワンショットセットアップスクリプト
├── bash/              # Bash設定
│   └── bashrc
├── fish/              # Fish Shell設定
│   ├── config.fish
│   ├── functions/
│   └── conf.d/
├── git/               # Git設定
│   ├── gitconfig
│   └── gitignore_global
├── starship/          # Starshipプロンプト設定
│   └── starship.toml
├── mise/              # mise設定
│   └── mise.toml
└── .vscode/           # VS Code設定
    ├── settings.json
    └── extensions.json
```

## 📝 Notes

- **Fish Shell**: デフォルトシェルとして自動設定されます
- **Git設定**: `gitconfig`と`gitignore_global`をシンボリックリンクで適用
- **Docker**: WSL2環境用に最適化された設定
- **VS Code**: ターミナルのデフォルトシェルもFishに設定

## 🦀 RustOwl Extension Colors

VS Code設定に含まれるRustOwl拡張機能のカラースキーム：

| Feature | Color | HSL Value | Description |
|---------|-------|-----------|-------------|
| **Immutable Borrow** | Cyan (明るい青) | `hsla(200, 100%, 50%, 0.8)` | 不変借用を示す下線 |
| **Lifetime** | White (白) | `hsla(0, 0%, 100%, 0.8)` | ライフタイムを示す下線 |
| **Move/Call** | Yellow (黄色) | `hsla(60, 100%, 50%, 0.8)` | ムーブ/関数呼び出しを示す下線 |
| **Mutable Borrow** | Red (赤) | `hsla(0, 100%, 50%, 0.8)` | 可変借用を示す下線 |
| **Outlive** | Gray (灰色) | `hsla(0, 0%, 50%, 0.8)` | ライフタイム制約を示す下線 |
