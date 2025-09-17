# Dotfiles

## Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ksera524/dotfiles/main/bootstrap.sh)
```

このコマンドは以下を実行します：
1. dotfilesリポジトリのクローン
2. miseのインストールと設定
3. 開発ツールのインストール（Node.js, Rust, Python等）
4. Docker/Docker Composeのインストールとセットアップ（WSL2環境用）
5. VS Code設定の適用
6. Git設定の適用

### Docker セットアップ

WSL2環境にDocker/Docker Composeを自動的にインストールします。個別にDockerをセットアップする場合：

```bash
./setup-docker.sh
```

**注意**: Dockerグループへの追加後は、一度ログアウトして再ログインするか、`newgrp docker`を実行してください。

## mise による開発ツール管理

### インストールされるツール

`.mise.toml`に定義された開発ツールが`install.sh`で自動的にインストールされます：

- **言語ランタイム**: Node.js (LTS), Rust (stable), Python 3.12
- **CLIツール**: GitHub CLI, ripgrep, fd, bat, eza
- **コンテナ**: Docker, Docker Compose

### miseの使い方

```bash
# インストール済みツールの確認
mise list

# グローバルにツールをインストール
mise use --global node@20
mise use --global rust@1.75

# プロジェクト固有のバージョン設定
mise use node@18  # プロジェクトの.mise.tomlに保存される

# 特定のツールを更新
mise upgrade node

# すべてのツールを更新
mise upgrade --all
```

### dotfilesの更新をpush

どこからでもdotfilesの変更をpushできるスクリプトが用意されています：

```bash
# デフォルトメッセージでpush
dotpush

# カスタムメッセージでpush
dotpush "Add new aliases"
```

このコマンドは以下を自動的に実行します：
1. `~/dotfiles`ディレクトリに移動
2. 変更をステージング（`git add -A`）
3. コミットを作成
4. GitHubにpush
5. 元のディレクトリに戻る

## VS Code Settings

### RustOwl Extension Colors

| Feature | Color | HSL Value | Description |
|---------|-------|-----------|-------------|
| **Immutable Borrow** | Cyan (明るい青) | `hsla(200, 100%, 50%, 0.8)` | 不変借用を示す下線 |
| **Lifetime** | White (白) | `hsla(0, 0%, 100%, 0.8)` | ライフタイムを示す下線 |
| **Move/Call** | Yellow (黄色) | `hsla(60, 100%, 50%, 0.8)` | ムーブ/関数呼び出しを示す下線 |
| **Mutable Borrow** | Red (赤) | `hsla(0, 100%, 50%, 0.8)` | 可変借用を示す下線 |
| **Outlive** | Gray (灰色) | `hsla(0, 0%, 50%, 0.8)` | ライフタイム制約を示す下線 |
