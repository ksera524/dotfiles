# Repository Guidelines

## Project Structure & Module Organization
This repository is a WSL (Ubuntu) and macOS dotfiles setup managed by Nix Flakes + Home Manager:
- `bootstrap.sh`: entry point that validates user context and delegates to `scripts/switch.sh`.
- `scripts/bootstrap-prereq.sh`: installs Nix and prepares local prerequisites.
- `scripts/switch.sh`: runs `nix run .#switch --impure`.
- `flake.nix` / `flake.lock`: flake inputs, app entrypoints, and lockfile.
- `home/`: Home Manager modules (`common.nix`, `linux.nix`, `darwin.nix`, `modules/`).
- `home.local.nix.sample`: local, machine-specific overrides template.
- `bash/`: Bash configuration (`bashrc`).
- `fish/`: Fish shell config (`config.fish`, `conf.d/`, `functions/`).
- `git/`: Git config and global ignore.
- `mise/`: tool definitions (`mise.toml`).
- `starship/`: prompt config (`starship.toml`).
- `.vscode/`: VS Code settings and extensions list.
- `.github/workflows/`: CI workflow (flake check + Home Manager switch).

## Build, Test, and Development Commands
- `./bootstrap.sh`: run full setup locally (WSL Ubuntu or macOS).
- `nix flake check --impure`: validate flake outputs and checks.
- `nix run .#switch --impure`: apply Home Manager configuration.
- `mise install`: install tools listed in `mise/mise.toml`.
- `mise list --current`: verify installed tool versions.

## Coding Style & Naming Conventions
- Shell scripts: follow existing style (2-space indent in `bootstrap.sh`).
- Fish scripts: follow existing style (4-space indent in `fish/` files).
- Keep paths relative to `$HOME` (avoid hardcoded absolute usernames).
- No dedicated formatter or linter; keep changes minimal and consistent with surrounding files.

## Testing Guidelines
There is no unit test framework. CI validates reproducibility by:
- running `nix flake check --impure`
- running `nix run .#switch --impure`
- verifying core tool availability (see `.github/workflows/ci.yml`)
If you add tests or checks, document how to run them in this file.

## Commit & Pull Request Guidelines
Commit history uses short, imperative messages (e.g., `Update dotfiles`, `Fix bootstrap.sh ...`).
Follow this pattern unless a more specific scope is needed.

PRs should include:
- a brief description of the change and why it is needed
- notes on WSL impact (if applicable)
- confirmation that CI passes (or why it does not)

## WSL/macOS/CI Notes
- WSL and macOS are supported.
- macOS requires Xcode Command Line Tools (`xcode-select --install`).
- Run bootstrap/switch as a normal user, not with `sudo`.
