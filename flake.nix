{
  description = "Cross-platform dotfiles with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }:
    let
      overlayGhqBinary = system: final: prev: {
        ghq = prev.stdenvNoCC.mkDerivation (finalAttrs: let
          assets = {
            x86_64-linux = {
              archive = "ghq_linux_amd64.zip";
              hash = "sha256-jLdaNSb0j9+pSxlvPtmbMA6T8II1CG44ObvB/jdER+g=";
              dir = "ghq_linux_amd64";
            };
            x86_64-darwin = {
              archive = "ghq_darwin_amd64.zip";
              hash = "sha256-tTJ4ecveqXKUPlHEujjtDLx9xE1LsYCBkkOOlfSKeds=";
              dir = "ghq_darwin_amd64";
            };
            aarch64-darwin = {
              archive = "ghq_darwin_arm64.zip";
              hash = "sha256-HjgLuqebmsYd391uZo2ou0wVJXo56vShpu/854kqjEI=";
              dir = "ghq_darwin_arm64";
            };
          };
          asset =
            assets.${system}
            or (throw "Unsupported system for ghq 1.9.2: ${system}");
        in {
          pname = "ghq";
          version = "1.9.2";

          src = prev.fetchurl {
            url = "https://github.com/x-motemen/ghq/releases/download/v${finalAttrs.version}/${asset.archive}";
            hash = asset.hash;
          };

          nativeBuildInputs = [
            prev.unzip
            prev.installShellFiles
          ];

          sourceRoot = asset.dir;

          installPhase = ''
            runHook preInstall

            install -Dm755 ghq "$out/bin/ghq"
            installShellCompletion \
              --bash misc/bash/_ghq \
              --zsh misc/zsh/_ghq

            runHook postInstall
          '';

          meta = prev.ghq.meta // {
            sourceProvenance = with prev.lib.sourceTypes; [ binaryNativeCode ];
          };
        });
      };

      mkHome = { system, profile }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ (overlayGhqBinary system) ];
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
            overlays = [ (overlayGhqBinary system) ];
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
