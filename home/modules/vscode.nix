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
      ".config/Code/User/extensions.json".source = extensionsSource;
      ".vscode-server/data/Machine/settings.json".source = settingsSource;
      ".vscode-server/data/Machine/extensions.json".source = extensionsSource;
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      "Library/Application Support/Code/User/settings.json".source = settingsSource;
      "Library/Application Support/Code/User/extensions.json".source = extensionsSource;
    })
  ];
}
