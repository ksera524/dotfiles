# Dotfiles

Nix Flakes + Home Manager で管理する、macOS と Ubuntu (WSL) 向けの dotfiles です。

## クイックスタート

```bash
git clone https://github.com/ksera524/dotfiles.git
cd dotfiles
./bootstrap.sh
```

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
- VS Code 推奨拡張をインストール: `dotfiles-vscode-extensions`
- bootstrap ラッパーを再実行: `./scripts/switch.sh`

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
