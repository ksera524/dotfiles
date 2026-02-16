# Dotfiles

macOS and Ubuntu (WSL) dotfiles managed by Nix Flakes + Home Manager.

## Quick Start

```bash
git clone https://github.com/ksera524/dotfiles.git
cd dotfiles
./bootstrap.sh
```

`bootstrap.sh` runs `scripts/switch.sh`, which installs prerequisites and applies the Home Manager config.

## Personal Settings

Git identity is intentionally not hardcoded in tracked Nix modules.

```bash
cp home.local.nix.sample ~/.config/dotfiles/home.local.nix
$EDITOR ~/.config/dotfiles/home.local.nix
```

At minimum, set:

```nix
programs.git.userName = "Your Name";
programs.git.userEmail = "you@example.com";
```

## Commands

- Apply config: `nix run .#switch --impure`
- Install VS Code recommended extensions: `dotfiles-vscode-extensions`
- Re-run bootstrap wrapper: `./scripts/switch.sh`

## Structure

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

## Notes

- `bootstrap.sh --legacy` keeps the previous `wsl.sh` / `mac.sh` flow available while migrating.
- Docker installation and privileged OS-level setup are intentionally outside Home Manager scope.
- WSL and macOS are first-class targets; CI validates both.
