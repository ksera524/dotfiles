{
  description = "Cross-platform dotfiles with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    let
      mkHome = { system, profile }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            ({ lib, ... }:
              let
                envUser = builtins.getEnv "USER";
                envHome = builtins.getEnv "HOME";
              in
              {
                home.username = lib.mkDefault (if envUser != "" then envUser else "user");
                home.homeDirectory = lib.mkDefault (
                  if envHome != "" then envHome
                  else if builtins.match ".*-darwin" system != null then "/Users/user"
                  else "/home/user"
                );
                home.stateVersion = "24.11";
              })
            ./home/common.nix
            (if profile == "darwin" then ./home/darwin.nix else ./home/linux.nix)
          ];
        };
    in
    {
      homeConfigurations = {
        linux = mkHome {
          system = "x86_64-linux";
          profile = "linux";
        };
        darwin = mkHome {
          system = "aarch64-darwin";
          profile = "darwin";
        };
        darwin-intel = mkHome {
          system = "x86_64-darwin";
          profile = "darwin";
        };
      };
    }
    // flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          profileKey =
            if system == "x86_64-linux" then "linux"
            else if system == "x86_64-darwin" then "darwin-intel"
            else "darwin";
        in
        {
          apps.switch = {
            type = "app";
            program = toString (pkgs.writeShellScript "dotfiles-switch" ''
              set -euo pipefail
              exec ${home-manager.packages.${system}.home-manager}/bin/home-manager switch -b hm-bak --impure --flake ${self}#${profileKey} "$@"
            '');
          };

          checks.home-activation = self.homeConfigurations.${profileKey}.activationPackage;
        });
}
