# Dotfiles

Nix Flakes + Home Manager で管理する、macOS と Ubuntu (WSL) 向けの dotfiles です。

## クイックスタート

```bash
git clone https://github.com/ksera524/dotfiles.git
cd dotfiles
./bootstrap.sh
```

この設定ではシステムのログインシェルは bash のままにし、対話型の bash セッション開始時に fish を起動します。

`bootstrap.sh` は `sudo` ではなく通常ユーザーで実行してください。

`bootstrap.sh` は `scripts/switch.sh` を呼び出し、前提ツールの準備と Home Manager 設定の適用を行います。

## 個人設定

Git のユーザー情報は、追跡対象の Nix モジュールにはあえて固定していません。

```bash
cp home.local.nix.sample ~/.config/dotfiles/home.local.nix
$EDITOR ~/.config/dotfiles/home.local.nix
```

最低限、次を設定してください:

```nix
programs.git.userName = "Your Name";
programs.git.userEmail = "you@example.com";
```

## コマンド

- 設定を適用: `nix run .#switch --impure`
- 入力整合性チェック: `nix flake check --impure`
- VS Code 推奨拡張をインストール: `dotfiles-vscode-extensions`
- bootstrap ラッパーを再実行: `./scripts/switch.sh`

## Nixの使い方（このリポジトリ）

### 1) ツールを追加する

`home/modules/packages.nix` の `home.packages` にパッケージを追加して適用します。

```nix
# home/modules/packages.nix
home.packages = with pkgs; [
  jq
  ripgrep
  # 追加したいパッケージ
  fd
];
```

```bash
nix run .#switch --impure
```

### 2) ツールを削除する

`home/modules/packages.nix` から対象を消して、再度適用します。

```bash
nix run .#switch --impure
```

### 3) 一時的にツールを試す（インストールしない）

```bash
# 1コマンドだけ実行
nix shell nixpkgs#jq -c jq --version

# シェルに一時的に入る
nix shell nixpkgs#ripgrep
```

### 4) パッケージ検索

```bash
nix search nixpkgs <keyword>
```

例: `nix search nixpkgs ghq`

### 5) flake input を更新する

```bash
# 全inputを更新
nix flake update

# 特定inputのみ更新
nix flake lock --update-input nixpkgs
```

更新後は `flake.lock` の差分を確認し、問題なければコミットします。

Rust を公式 stable の最新へ追従したい場合は、`rust-overlay` も更新します。

```bash
nix flake lock --update-input rust-overlay
nix run .#switch --impure
rustc --version
cargo --version
```

### 6) 現在の構成で入るバージョン確認

```bash
# 例: ghq
nix eval --impure --raw .#homeConfigurations.linux.pkgs.ghq.version
```

macOS の場合は `linux` を `darwin` / `darwin-intel` に読み替えてください。

## 構成

```text
.
├── flake.nix
├── home/
│   ├── common.nix
│   ├── linux.nix
│   ├── darwin.nix
│   └── modules/
│       ├── packages.nix
│       ├── shell.nix
│       ├── git.nix
│       ├── starship.nix
│       └── vscode.nix
├── scripts/
│   ├── bootstrap-prereq.sh
│   └── switch.sh
└── home.local.nix.sample
```

## 補足

- Docker の導入や権限が必要な OS レベル設定は、意図的に Home Manager の責務から外しています。
- WSL と macOS を正式サポート対象とし、CI で両方を検証しています。
- Nix インストール直後に `nix` が見つからない場合は `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` を実行するか、新しいターミナルを開いてください。
