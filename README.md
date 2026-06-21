# Dotfiles

Nix Flakes + Home Manager で管理する、macOS と Ubuntu (WSL) 向けの dotfiles です。

## クイックスタート

```bash
mkdir -p ~/src/github.com/ksera524
git clone https://github.com/ksera524/dotfiles.git ~/src/github.com/ksera524/dotfiles
cd ~/src/github.com/ksera524/dotfiles
./bootstrap.sh
```

この設定ではシステムのログインシェルは bash のままにし、対話型の bash セッション開始時に fish を起動します。

`bootstrap.sh` は `sudo` ではなく通常ユーザーで実行してください。

`bootstrap.sh` は `scripts/switch.sh` を呼び出し、前提ツールの準備と Home Manager 設定の適用を行います。

このリポジトリは個人用 dotfiles のため、`~/.config/dotfiles/home.local.nix` の local override を優先し、`--impure` を前提にしています。

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

標準配置は `~/src/github.com/ksera524/dotfiles` です。別の場所に置く場合は local override で `DOTFILES_DIR` を指定してください:

```nix
home.sessionVariables.DOTFILES_DIR = "/path/to/dotfiles";
```

追跡対象外の個人設定は `~/.bashrc.local`、`~/.config/fish/config.local.fish`、`~/.config/dotfiles/home.local.nix` に置きます。bash/fish の正本は `home/modules/shell.nix` です。

## コマンド

- 設定を適用: `nix run .#switch --impure`
- 入力整合性チェック: `nix flake check --impure`
- VS Code 設定と推奨拡張 JSON のシンボリックリンクを更新: `nix run .#switch --impure`
- bootstrap ラッパーを再実行: `./scripts/switch.sh`

## カスタムコマンドと alias

### カスタムコマンド

| コマンド | 説明 |
| --- | --- |
| `ghq-cd` | `ghq list -p` の結果を `fzf` で選択して、そのリポジトリへ移動します。 |
| `dotfiles-bootstrap` | `DOTFILES_DIR`、または既定の `~/src/github.com/ksera524/dotfiles` で `nix run <dotfiles>#switch --impure` を実行します。 |
| `cdd` | dotfiles リポジトリへ移動します。 |
| `dotpush [message]` | dotfiles リポジトリの変更を `git add -A` し、指定メッセージまたは `Update dotfiles` で commit して push します。 |

### shell alias / abbreviation

fish では abbreviation、bash では alias として定義しています。通常は対話型 bash から fish に入るため、fish 側の定義が主に使われます。

| 名前 | 展開先 | 対象 |
| --- | --- | --- |
| `ll` | `ls -alF` | bash / fish |
| `la` | `ls -A` | bash / fish |
| `l` | `ls -CF` | bash / fish |
| `..` | `cd ..` | bash / fish |
| `...` | `cd ../..` | bash / fish |
| `....` | `cd ../../..` | bash / fish |
| `ls` | `eza` | bash / fish |
| `cat` | `bat` | bash / fish |
| `find` | `fd` | bash / fish |
| `grep` | `rg` | bash / fish |
| `gs` | `git status` | bash / fish |
| `ga` | `git add` | bash / fish |
| `gc` | `git commit` | bash / fish |
| `gd` | `git diff` | bash / fish |
| `gl` | `git log --oneline --graph --decorate` | bash / fish |
| `gp` | `git push` | bash / fish |
| `gpl` | `git pull` | bash / fish |
| `rm` | `rm -i` | bash / fish |
| `cp` | `cp -i` | bash / fish |
| `mv` | `mv -i` | bash / fish |
| `cc` | `claude --dangerously-skip-permissions` | bash / fish |
| `cx` | `codex --yolo` | bash / fish |
| `gq` | `ghq-cd` | fish |
| `cdp` | `cd ~/projects` | fish |
| `gco` | `git checkout` | fish |
| `gcb` | `git checkout -b` | fish |
| `gcm` | `git commit -m` | fish |
| `gca` | `git commit --amend` | fish |
| `grb` | `git rebase` | fish |
| `gst` | `git stash` | fish |
| `gstp` | `git stash pop` | fish |
| `dps` | `docker ps` | fish |
| `dpsa` | `docker ps -a` | fish |
| `di` | `docker images` | fish |
| `dc` | `docker compose` | fish |
| `dcu` | `docker compose up` | fish |
| `dcd` | `docker compose down` | fish |
| `dcl` | `docker compose logs` | fish |
| `update` | `sudo apt update && sudo apt upgrade` | fish / Linux |
| `ports` | `ss -tuln` | fish / Linux |

### Git alias

| alias | 展開先 |
| --- | --- |
| `git st` | `git status` |
| `git co` | `git checkout` |
| `git br` | `git branch` |
| `git cm` | `git commit` |
| `git df` | `git diff` |
| `git lg` | `git log --oneline --graph --decorate` |
| `git unstage` | `git reset HEAD --` |
| `git last` | `git log -1 HEAD` |
| `git visual` | `gitk` |
| `git amend` | `git commit --amend` |
| `git undo` | `git reset --soft HEAD~1` |
| `git branches` | `git branch -a` |
| `git remotes` | `git remote -v` |
| `git tags` | `git tag -l` |
| `git hist` | `git log --pretty=format:'%h %ad \| %s%d [%an]' --graph --date=short` |
| `git tree` | `git log --graph --pretty=format:'%C(yellow)%h%C(reset) - %C(green)%ad%C(reset) - %C(blue)%an%C(reset)%C(red)%d%C(reset) %s' --date=short --all` |
| `git contributors` | `git shortlog --summary --numbered` |

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

`nodejs_24`、`claude-code`、`codex`、`opencode` は unstable input 由来です。更新時は `nix flake update` 後に CI で Home Manager activation と smoke test を確認します。

Rust を公式 stable の最新へ追従したい場合は、`rust-overlay` も更新します。

```bash
nix flake lock --update-input rust-overlay
nix run .#switch --impure
rustc --version
cargo --version
```

`Cargo.lock` は global ignore しません。Rust の application/binary crate では lockfile を追跡し、library crate で不要な場合は各リポジトリの `.gitignore` に個別に追加します。

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
