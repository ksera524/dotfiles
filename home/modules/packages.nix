{ pkgs, lib, ... }:
{
  home.packages = with pkgs;
    [
      nodejs
      python312
      go
      rustc
      cargo
      rustfmt
      clippy
      gh
      ripgrep
      fd
      bat
      eza
      jq
      bottom
      ghq
      fzf
      tmux
      fish
      starship
      hugo
      nodePackages.typescript
    ]
    ++ lib.optionals stdenv.isLinux [
      lld
      pkg-config
      openssl
    ];
}
