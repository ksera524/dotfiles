{ pkgs, lib, ... }:
let
  settingsSource = ../../.vscode/settings.json;
  extensionsSource = ../../.vscode/extensions.json;
in
{
  home.file = lib.mkMerge [
    {
      ".config/dotfiles/vscode/extensions.json".source = extensionsSource;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      ".config/Code/User/settings.json".source = settingsSource;
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      "Library/Application Support/Code/User/settings.json".source = settingsSource;
    })
  ];

  home.packages = [
    (pkgs.writeShellScriptBin "dotfiles-vscode-extensions" ''
      set -euo pipefail

      if ! command -v jq >/dev/null 2>&1; then
        echo "jq is required" >&2
        exit 1
      fi

      if ! command -v code >/dev/null 2>&1; then
        echo "VS Code 'code' command is not available" >&2
        exit 1
      fi

      jq -r '.recommendations[]' "${extensionsSource}" | while read -r ext; do
        code --install-extension "$ext" --force
      done
    '')
  ];
}
