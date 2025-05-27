{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ksera";
  home.homeDirectory = "/home/ksera";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # Development tools
    pkgs.gh                    # GitHub CLI
    pkgs.nodejs_22             # Node.js (latest LTS)
    pkgs.mold                  # Fast linker
    
    # Rust toolchain - using Nix packages for better integration
    pkgs.rustc                 # Rust compiler
    pkgs.cargo                 # Cargo package manager
    pkgs.rustfmt               # Rust formatter
    pkgs.clippy                # Rust linter
    pkgs.rust-analyzer         # Rust language server
    
    # Additional Rust tools
    pkgs.cargo-watch          # Auto-rebuild on file changes
    pkgs.cargo-edit           # cargo add/rm/upgrade commands
    pkgs.cargo-outdated       # Check for outdated dependencies
    pkgs.cargo-audit          # Security audit for dependencies
    
    # Build tools
    pkgs.gcc
    pkgs.gnumake
    pkgs.binutils
    pkgs.glibc
    pkgs.stdenv.cc
    pkgs.pkg-config
    pkgs.openssl
    
    
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ksera/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    RUSTFLAGS = "-C linker=mold -C link-arg=-fuse-ld=mold"; # Rustのビルドでmoldを使う
    RUST_BACKTRACE = "1";      # Rustのエラー時にバックトレースを表示
    CARGO_INCREMENTAL = "1";   # インクリメンタルコンパイルを有効化
  };

  programs.git = {
    enable = true;

    userName = "ksera524";
    userEmail = "ksera631@gmail.com";

    lfs.enable = true;

    delta = {
      enable = true;
      options = {
        line-numbers = true;
        theme = "OneHalfDark";
      };
    };

    aliases = {
      co = "checkout";
      br = "branch -vv";
      st = "status -sb";
    };

    extraConfig = {
      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = true;
      push.autoSetUpRemote = true;
      core.editor = "vim";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}