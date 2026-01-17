# Repository Guidelines

## Project Structure & Module Organization
This repository is a WSL (Ubuntu) dotfiles setup with a single entry point:
- `bootstrap.sh`: one-shot setup script (packages, mise, symlinks, Docker, VS Code, fish).
- `bash/`: Bash configuration (`bashrc`).
- `fish/`: Fish shell config (`config.fish`, `conf.d/`, `functions/`).
- `git/`: Git config and global ignore.
- `mise/`: tool definitions (`mise.toml`).
- `starship/`: prompt config (`starship.toml`).
- `.vscode/`: VS Code settings and extensions list.
- `.github/workflows/`: CI workflow (bootstrap in CI mode).

## Build, Test, and Development Commands
- `./bootstrap.sh`: run full setup locally (WSL Ubuntu expected).
- `./bootstrap.sh --ci`: CI-safe setup (skips WSL-only steps like Docker install, shell change).
- `mise install`: install tools listed in `mise/mise.toml`.
- `mise list --current`: verify installed tool versions.

## Coding Style & Naming Conventions
- Shell scripts: follow existing style (2-space indent in `bootstrap.sh`).
- Fish scripts: follow existing style (4-space indent in `fish/` files).
- Keep paths relative to `$HOME` (avoid hardcoded absolute usernames).
- No dedicated formatter or linter; keep changes minimal and consistent with surrounding files.

## Testing Guidelines
There is no unit test framework. CI validates reproducibility by:
- running `./bootstrap.sh --ci`
- verifying symlinks and tool availability (see `.github/workflows/ci.yml`)
If you add tests or checks, document how to run them in this file.

## Commit & Pull Request Guidelines
Commit history uses short, imperative messages (e.g., `Update dotfiles`, `Fix bootstrap.sh ...`).
Follow this pattern unless a more specific scope is needed.

PRs should include:
- a brief description of the change and why it is needed
- notes on WSL impact (if applicable)
- confirmation that CI passes (or why it does not)

## WSL/CI Notes
- The project assumes WSL Ubuntu for local setup. Non-WSL usage may require `--skip-wsl-check`.
- CI uses `--ci` and may skip Docker, VS Code extensions, and default shell changes.
