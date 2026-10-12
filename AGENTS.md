# Repository Guidelines

## Project Structure & Module Organization
This repository is an Ubuntu (WSL) and macOS dotfiles setup managed by mise:
- `install.sh`: piped mise installer with a fixed ~/src checkout; mise bootstrap --from manages Git/clone/trust.
- `mise.toml`: entrypoint, includes, bootstrap files/repos/hooks, and dotfile links.
- `mise/tools.toml` / `mise/packages.toml`: runtime/CLI tools and apt/brew packages.
- `mise/aliases.toml`: shared Bash/Fish aliases. Startup files use dotfile edits and bootstrap.mise_shell_activate.
- `mise/conf.d/platform/`: OS/architecture-specific environment and login shells.
- `mise/conf.d/tasks/mise.toml`: bootstrap helper tasks.
- `mise/tracking.toml`: global track-mode declarations for local overrides and SSH config; no remote or watcher is configured.
- `linux/apt/`: official Docker/Tailscale public signing keys; vendor sources are managed by bootstrap.files before packages.
- `.miserc.toml`: enable automatic platform configuration.
- `shell/`: Bash and Fish configuration and custom functions.
- `git/`: shared Git config, global ignore, and personal config sample.
- SSH config/authorized_keys stay on each machine and use local mise track history; private keys and host history stay untracked and outside Git.
- `.vscode/`: VS Code settings and recommended extensions.
- `.github/workflows/ci.yml`: hosted-runner bootstrap and status checks on Ubuntu and macOS.

## Build, Test, and Development Commands
- `bash install.sh`: install prerequisites, clone or reuse the ghq-layout checkout, then bootstrap.
- `bash -n install.sh`: validate the installer syntax.
- `mise trust`: trust the checkout (requires mise 2026.10.8 or later).
- `mise bootstrap repos apply`: fetch Pure before the first dotfile dry run.
- `mise bootstrap --dry-run`: preview machine setup.
- `mise bootstrap`: apply packages, tools, and dotfiles as a normal user.
- `mise bootstrap user apply --dry-run`: preview login shell changes.
- `mise dot apply`: apply only dotfiles.
- `mise dot save` / `mise dot history`: save and inspect local tracked-file history.
- `mise dot status --missing`: fail if any declared dotfile is not applied.
- `bash -n shell/bashrc` and `bash -n shell/bash_profile`: validate Bash syntax.
- `fish --no-execute <file>`: validate each Fish file separately.

## Coding Style & Naming Conventions
- Prefer declarative mise env/dotfiles/packages/repos/user over custom installation scripts.
- Keep shared environment and PATH definitions in mise; shell files should focus on abbreviations, prompts, and functions. Use bootstrap.mise_shell_activate for activation and shell_alias for shared aliases.
- Put non-declarative setup in bootstrap:* tasks. Hooks should only invoke tasks at required phases with --skip-tools; the bootstrap task runs last.
- Bash uses 2-space indentation; Fish uses 4 spaces.
- Keep home paths relative to `$HOME` or `~/`; avoid hardcoded usernames.
- No dedicated formatter or linter; keep changes consistent with surrounding files.

## Testing Guidelines
CI runs bootstrap on disposable hosted runners with --force-dotfiles, applying only
`bootstrap.user` through sudo to change the original runner user's login shell
without a PAM password prompt. It then checks
`mise bootstrap status --missing` and
`mise bootstrap dotfiles status --missing`. Any declared state that differs
fails CI. CI also checks startup-file preservation and idempotence, then starts
Bash/Fish to verify shared aliases, functions, and Node.
OS package installation modifies the CI runner. Locally, use an isolated home
for deployment tests to avoid changing the user's configuration.
See README.md for syntax checks and migration instructions.

## Commit & Pull Request Guidelines
Commit history uses short, imperative messages (e.g., `Update dotfiles`, `Migrate dotfiles to mise`).
Follow this pattern unless a more specific scope is needed.

PRs should include:
- a brief description of the change and why it is needed
- notes on WSL impact (if applicable)
- confirmation that CI passes (or why it does not)

## WSL/macOS/CI Notes
- WSL and macOS are supported.
- macOS requires Xcode Command Line Tools (`xcode-select --install`); Intel Macs also require native Homebrew.
- Run `mise bootstrap` as a normal user; mise handles sudo for apt packages.
- `shell/` is the source of truth for shell config. Personal overrides belong in `~/.bashrc.local`, `~/.config/fish/config.local.fish`, `~/.config/mise/config.local.toml`, and `~/.gitconfig.local`.
