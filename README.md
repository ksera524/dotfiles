# Dotfiles

mise で管理する Ubuntu (WSL)・macOS 向けの dotfiles です。開発ツール、OS パッケージ、Pure の取得、設定ファイルのリンクを `mise bootstrap` で適用します。`install.sh` は mise の導入を担当し、Git の準備・clone・環境設定は `mise bootstrap --from` に任せます。

## 初回セットアップ

curl と Bash があれば、次のコマンドで mise・Git の導入、clone、`mise bootstrap` を順に実行できます。macOS は Xcode Command Line Tools (`xcode-select --install`) が必要で、Intel Mac のみ [Homebrew](https://brew.sh/) を事前に用意します。

```bash
curl -fsSL https://raw.githubusercontent.com/ksera524/dotfiles/main/install.sh | bash
```

clone 先は `~/src/github.com/ksera524/dotfiles` に統一しています。既存の checkout は mise が再利用し、`--update` で fast-forward 更新します。別リポジトリや衝突するディレクトリは mise が拒否します。

Bash・Fish の起動ファイルは mise の部分編集で管理します。既存の通常ファイルを保持し、共有設定の読み込みと activation を追加するため、Ubuntu 標準の `.bashrc` も退避不要です。Home Manager の旧リンクは、先に下記の移行手順で退避してください。Git・VS Code など全体をリンクする配置先の通常ファイルは、事前に退避が必要です。

手動で clone 済み・mise 導入済みの場合は、任意の配置先で直接適用できます (`install.sh` は常に上記の標準配置先を使います):

```bash
mise trust
mise bootstrap --update
```

初回適用前にプレビューする場合は `mise bootstrap repos apply` で Pure を取得してから `mise bootstrap --dry-run` を実行します。

通常ユーザーで実行してください。Ubuntu の OS パッケージ導入時には mise が必要な `sudo` を呼び出します。Apple Silicon の OS パッケージは mise 内蔵の `brew` パッケージ管理で導入します (Homebrew 本体の事前インストールは不要)。内蔵機能が対応していない Intel Mac のみ、短い mise タスクで native Homebrew を呼び出します。

`bootstrap.user.login_shell` でログインシェルを Fish に変更します。適用時に `chsh` や `/etc/shells` の更新のため、パスワード入力が必要になる場合があります。適用後はログインし直すか、新しいログインセッションを開いてください。Bash から Fish への自動切り替えは行いません。

| 環境 | ログインシェル |
| --- | --- |
| Ubuntu / WSL | `/usr/bin/fish` |
| macOS Apple Silicon | `/opt/homebrew/bin/fish` |
| macOS Intel | `/usr/local/bin/fish` |

`.miserc.toml` の `auto_env = true` で OS・アーキテクチャ別設定を読み込みます。同じ設定をグローバルな `~/.config/mise/miserc.toml` にも配置し、リポジトリ外からの bootstrap にも反映します。Intel Mac の Fish は `pre-packages` フックから `bootstrap:host-packages` タスクを呼び、ログインシェル変更より前に導入します。

```bash
mise bootstrap user status
mise bootstrap user apply --dry-run
mise bootstrap user apply
```

`user apply` だけを実行する場合は、先に Fish を導入してください。

## Home Manager からの切り替え

既存マシンでは、初回セットアップの適用前に次を行います。実ファイルは mise が競合として保護しますが、既存シンボリックリンクは再リンクされるため、先にバックアップしてください。`--force` を常用する必要はありません。

1. `~/.config/dotfiles/home.local.nix` の個人設定を確認し、Git の名前・メールなどを下記の個人設定へ移します。現在の Git 設定は `git config --global --list --show-origin` で確認できます。
2. Home Manager が管理していた Bash・Git・VS Code の設定を退避します。Nix 削除後も参照したい設定は `cp -L` などでリンク先の内容も保存します。既存 `~/.gitconfig` が古い設定を読み込んでいる場合も確認してください。
3. Fish の旧設定を以下のように退避します。古い `conf.d/env.fish` や `plugin-pure.fish` が残ると、Nix の環境変数や旧 Pure を読み込むため、設定ディレクトリ全体を入れ替えます。退避先がすでにある場合は別名を選んでください。

```bash
mv ~/.config/fish ~/.config/fish.home-manager-backup
```

4. 初回セットアップを実行します。必要な `config.local.fish`、`fish_variables`、個人の `functions/` は退避先から選んで戻してください。Home Manager の生成ファイルは戻しません。
5. 新しいターミナルで `mise dot status --missing`、`mise exec -- node --version`、`mise exec -- rustc --version` を確認します。旧 `OPENSSL_DIR`・`OPENSSL_LIB_DIR`・`OPENSSL_INCLUDE_DIR`・`PKG_CONFIG_PATH` が Nix を指していないか確認し、独自のシェル設定に残した Nix 初期化も取り除きます。

このリポジトリへの変更だけで、インストール済み Nix や Home Manager はアンインストールされません。新しい環境の確認後、使用した Nix インストーラーのアンインストール手順に従って削除できます。

## 個人設定

Git のユーザー情報は追跡対象に含めません。

```bash
cp git/gitconfig.local.sample ~/.gitconfig.local
$EDITOR ~/.gitconfig.local
```

共通 Git 設定は `~/.config/git/config` から `~/.gitconfig.local` を最後に読み込みます。既存の個人設定がある場合は、サンプルで上書きせず編集してください。

| 用途 | 配置先 |
| --- | --- |
| Bash の個人設定 | `~/.bashrc.local` |
| Fish の個人設定 | `~/.config/fish/config.local.fish` |
| グローバルな mise 設定の上書き | `~/.config/mise/config.local.toml` |
| このリポジトリだけの mise 設定の上書き | `mise.local.toml` (Git 管理外) |
| Git の個人設定 | `~/.gitconfig.local` |

`~/.config/mise/conf.d/dotfiles` はこのリポジトリへのリンクです。mise はこのフォルダをグローバル設定として読むため、開発ツールは他のディレクトリでも利用できます。clone 先は任意です。`DOTFILES_DIR` はこのリンクを指します。

## track mode によるローカル履歴

`mise/tracking.toml` を `~/.config/mise/conf.d/dotfiles-tracking.toml` に配置し、次の実ファイルを `mode = "track"` で管理します。tracking はグローバル設定にのみ対応しているため、リポジトリの配置定義とは分けています。

- `~/.bashrc.local`
- `~/.config/fish/config.local.fish`
- `~/.config/mise/config.local.toml`
- `~/.config/mise/miserc.local.toml`
- `~/.gitconfig.local`
- `~/.ssh/config`
- `~/.ssh/authorized_keys`

track mode はファイルを移動したり symlink に変えたりせず、現在の場所で編集した内容の履歴を保存します。ファイルがまだない場合は作成せず、作成後から内容を保存できます。共有シェル・Git・VS Code 設定の配置は既存の `[dotfiles]` に任せます。

```bash
mise dot save --description "Update local settings"  # 現在の内容を保存
mise dot history                                   # 履歴を一覧
mise dot rollback ~/.bashrc.local --dry-run         # 復元内容を確認
mise dot rollback ~/.bashrc.local                   # 以前の内容へ戻す
mise dot undo                                      # 復元操作を取り消す
```

有効化後は bootstrap などの変更操作の前後にもチェックポイントが保存されます。履歴は mise の state ディレクトリ (`~/.local/state/mise/history/repo.git`) に保存され、この dotfiles リポジトリには入りません。`sync = "manual"` とし、リモート・監視サービスは設定していません。編集のたびに保存したい場合は上記の `mise dot save` を実行します。

秘密鍵・`known_hosts`・シェル履歴は追跡対象に含めていません。ローカル設定に含まれる機密情報も履歴に残り得るため、機器間同期を追加する際は暗号化設定を含めて対象を見直してください。

## SSH

`~/.ssh/config` と `~/.ssh/authorized_keys` は各 PC の実ファイルを track mode で履歴管理します。ファイルを共有リポジトリから配布したり、ほかの PC のキーで上書きしたりしません。既存内容はそのまま編集でき、履歴は `mise dot save` で保存します。

既存の `~/.ssh` は `0700`、`config` と `authorized_keys` は `0600` に揃えます。権限は `[dotfiles]` の `permissions` で宣言し、chmod 用のフック・タスクは不要です。まだ存在しないファイルは自動生成しません。

秘密鍵と `known_hosts` (接続履歴) は追跡対象外です。SSH ファイルはこのリポジトリの Git 管理からも除外しています。

## mise に集約する設定

`[env]` と OS 別の `mise/conf.d/platform/mise.*.toml` が、locale・ブラウザー・Rust リンカー・OpenSSL・GOPATH と追加 PATH を管理します。Bash / Fish で同じ値を二重定義せず、`mise exec` から実行したコマンドにも反映します。個人の環境変数は `~/.config/mise/config.local.toml`、このリポジトリ内の上書きは `mise.local.toml` に置いてください。

インストーラーの Git 導入・clone・checkout 検証・信頼設定は `mise bootstrap --from --from-dir` に委ねています。mise が入っていれば、同じセットアップを直接実行できます:

```bash
mise bootstrap --from https://github.com/ksera524/dotfiles.git \
  --from-dir "$HOME/src/github.com/ksera524/dotfiles" --yes --update
```

宣言だけでは表せない補助処理は `mise/conf.d/tasks/mise.toml` の `bootstrap:*` タスクにまとめます。

| タスク | 処理 | 呼び出し元 |
| --- | --- | --- |
| `bootstrap` | インストーラーから受け取った ghq ルートを個人 Git 設定に保存 | bootstrap の最後 |
| `bootstrap:host-packages` | Intel Mac の Homebrew パッケージ導入 | `pre-packages` フック |

フックには適用順を指定するタスク呼び出しだけを置きます。初期セットアップの途中で開発ツールを先にインストールしないよう、呼び出しには `mise run --skip-tools` を使います。通常の `bootstrap` タスクは全体の最後なので、Fish 導入のように順序が必要な処理は対応するフェーズで実行します。

Bash / Fish に残すのは履歴設定、Fish 固有の abbreviation、プロンプト、シェル自身を操作する関数です。共通 alias は `mise/aliases.toml` の `[shell_alias]` に集約しています。

起動ファイルへの共有設定の読み込みは `[dotfiles]` の部分編集、activation は `[bootstrap.mise_shell_activate]` に任せます。mise 起動前に必要な PATH だけを先頭に追加します。Bash のログインシェルには標準機能で shims が入り、非対話処理でプロジェクトに応じたツールを選べます。非対話処理でも mise の環境変数が必要な場合は `mise exec -- <command>` を使います。

この PR の旧構成を適用済みの場合は、`~/.bashrc`・`~/.bash_profile`・`~/.config/fish/config.fish` のリポジトリへのリンクを退避してから再適用してください。部分編集先が共有ファイルを指したままにならないようにします。

## 日常の操作

```bash
mise bootstrap                  # OS パッケージ・ツール・dotfiles を適用
mise dot apply --dry-run         # 設定ファイルの配置をプレビュー
mise dot apply                  # 設定ファイルだけを適用
mise dot status --missing       # 未適用があれば終了コード 1
mise install                    # 設定済みの開発ツールを導入
mise upgrade                    # 許容バージョンの範囲で開発ツールを更新
mise exec jq -- jq --version     # 一時的にツールを利用
mise registry                   # 利用できるツールを調べる
```

ツール追加は `mise/tools.toml` の `[tools]` を編集します。Rust は公式 stable (rust-src・rustfmt・clippy を含む) を使います。`latest` は最新版へ追従します。プロジェクト固有のバージョンは各プロジェクトの mise 設定で上書きします。

OS パッケージは `mise/packages.toml` の `[bootstrap.packages]` を編集します。`apt:` は Ubuntu、`brew:` は Apple Silicon 用です。Intel Mac にも追加する場合は `mise/conf.d/tasks/mise.toml` の `[tasks."bootstrap:host-packages"]` を更新します。Ubuntu の Rust は clang + mold を使い、OpenSSL の開発ファイルは OS のパッケージから取得します。macOS は Homebrew の OpenSSL と pkgconf を導入します。

エントリーを削除してもインストール済みのツールや OS パッケージは自動削除されません。不要なものは利用状況を確認して各パッケージマネージャーで削除してください。

## Docker・SSH サーバー・Tailscale (Ubuntu / WSL)

次の OS パッケージを `[bootstrap.packages]` で管理します。mise が apt を呼び出して導入状況を揃え、既存のインストールも利用します。

- Docker: `containerd.io`、`docker-ce`、`docker-ce-cli`、`docker-buildx-plugin`、`docker-compose-plugin`
- SSH サーバー: `openssh-server`
- Tailscale: `tailscale`、`tailscale-archive-keyring`

Docker・Tailscale の公式署名鍵は `linux/apt/` に保存しています。`bootstrap.files` がパッケージ導入前に `/etc/apt/keyrings/` と `/etc/apt/sources.list.d/` に配置します。Ubuntu のリリース名と CPU アーキテクチャはマシンから取得します。

既存の `docker.list` と `tailscale.list` は mise の定義で更新します。同じリポジトリを指す `docker.sources` / `tailscale.sources` は、署名鍵のパスが競合しないよう削除対象にしています。独自に編集した定義がある場合は、初回適用前に内容を確認してください。

```bash
mise bootstrap --update                    # リポジトリ配置・apt 情報更新・導入
mise bootstrap status --missing            # 全体の状態確認
mise bootstrap packages upgrade --manager apt  # 管理する apt パッケージを更新
```

`install.sh` と CI は `--update` を付けて実行します。これらのパッケージと apt 定義は Linux のみが対象で、macOS には適用しません。

Tailscale の端末認証は `sudo tailscale up` で別途行います。Docker のユーザー権限やサービスの起動設定は必要に応じて OS 側で設定します。WSL で systemd を使う場合は `/etc/wsl.conf` の `[boot] systemd=true` が必要です。

参照: [Docker の公式 Ubuntu インストール手順](https://docs.docker.com/engine/install/ubuntu/)、[Tailscale の公式 Linux インストール手順](https://tailscale.com/docs/install/linux)。

## シェル

Pure v4.19.0 は `[bootstrap.repos]` で取得し、mise dotfiles で配置します。独自 Fish 関数は専用ディレクトリを関数検索パスに追加するため、個人の `functions/` と共存できます。

| コマンド | 動作 |
| --- | --- |
| `ghq-cd` / Fish の `gq` | ghq のリポジトリを fzf で選んで移動 |
| `dotfiles-bootstrap` | dotfiles で `mise bootstrap` を実行 (引数も転送) |
| `cdd` | dotfiles へ移動 |
| `dotpush [message]` | dotfiles の変更を add・commit・push |

共通ショートカットは Bash / Fish とも mise の alias として利用できます。共通分の Fish abbreviation は alias に変更したため、入力時の文字列展開は行いません。Fish 固有の abbreviation と Git alias は維持します。`ls` → eza、`cat` → bat、`find` → fd、`grep` → rg、`cc` → Claude Code、`cx` → Codex も利用できます。WSL は `wslview` がインストール済みならブラウザー起動に使い、それ以外は `xdg-open` を使います。

## 構成と検証

```text
.
├── README.md / AGENTS.md
├── install.sh                 インストーラーの入口
├── mise.toml                  mise の入口・設定ファイル配置
├── mise/
│   ├── tools.toml             ランタイム・開発 CLI
│   ├── packages.toml          apt / brew パッケージ
│   ├── tracking.toml          機器固有ファイルの履歴
│   └── conf.d/
│       ├── platform/          OS・アーキテクチャ別の環境・ログインシェル
│       └── tasks/             bootstrap 補助タスク
├── shell/                     Bash / Fish の設定
├── git/                       Git の設定
├── linux/apt/                 公式 apt 署名鍵
├── .vscode/                   VS Code 設定
└── .github/workflows/         CI
```

ルートの `.miserc.toml` は OS 別設定を有効にするための小さな入口です。`mise.toml` はツール・パッケージ定義を include し、`mise/conf.d/` のフォルダから OS 別設定とタスクを読み込みます。これらのフォルダはグローバルな `conf.d` にもリンクするため、リポジトリ外でも利用できます。

ローカルでの構文確認:

```bash
bash -n install.sh
bash -n shell/bashrc
bash -n shell/bash_profile
for file in shell/fish/config.fish shell/fish/conf.d/*.fish shell/fish/functions/*.fish; do
  fish --no-execute "$file" || break
done
```

CI は使い捨ての GitHub ホスト runner で bootstrap を実行し、次の状態確認で乖離があれば失敗します。runner 上で競合する他の dotfiles を置き換えるため、CI のみ `--force-dotfiles` を付けます。Bash・Fish の起動ファイルは部分編集で保持します。パッケージ・dotfiles は通常ユーザーで適用し、ログインシェルだけは CI のパスワード入力を避けるため `sudo mise bootstrap user apply` で元の runner ユーザーに適用します。

```bash
mise bootstrap status --missing
mise bootstrap dotfiles status --missing
```

`mise bootstrap status` は全ステップの状態を表示します。CI では `--missing` を付け、未導入・未適用も終了コード 1 にします。状態確認に加え、起動ファイルの既存内容と再適用時の冪等性、Bash・Fish の共通 alias・関数・Node の起動を確認します。OS パッケージは runner に導入されます。Docker の導入は検証対象です。ユーザー権限設定と Tailscale の認証は対象外です。

仕様: [mise bootstrap](https://mise.jdx.dev/bootstrap.html) / [mise dotfiles](https://mise.jdx.dev/dotfiles.html) / [conf.d フォルダ](https://mise.jdx.dev/configuration.html#conf-d-folders)。
