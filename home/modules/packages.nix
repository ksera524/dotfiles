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
      (pkgs."claude-code")
      pkgs.codex
      pkgs.opencode
    ]
    ++ lib.optionals stdenv.isLinux [
      clang
      lld
      mold
      nasm
      pkg-config
      openssl
    ];
}
