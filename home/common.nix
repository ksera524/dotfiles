{ lib, ... }:
let
  envHome = builtins.getEnv "HOME";
  localConfigPath =
    if envHome != "" then "${envHome}/.config/dotfiles/home.local.nix"
    else "/tmp/home.local.nix";
in
{
  imports =
    [
      ./modules/packages.nix
      ./modules/shell.nix
      ./modules/git.nix
      ./modules/starship.nix
      ./modules/vscode.nix
    ]
    ++ lib.optional (builtins.pathExists localConfigPath) (builtins.toPath localConfigPath);

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    NODE_ENV = "development";
  };

  xdg.enable = true;
}
