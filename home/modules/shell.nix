{ ... }:
{
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      ls = "eza";
      cat = "bat";
      find = "fd";
      grep = "rg";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate";
      gp = "git push";
      gpl = "git pull";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      dotfiles-bootstrap = "nix run ~/dotfiles#switch --impure";
      cc = "claude --dangerously-skip-permissions";
    };
    initExtra = ''
      export HISTSIZE=10000
      export HISTFILESIZE=20000
      export HISTCONTROL=ignoreboth:erasedups
      shopt -s histappend
      shopt -s checkwinsize

      ghq-cd() {
          local dest
          dest="$(ghq list -p | fzf --prompt='ghq> ' --height=40% --reverse)"
          if [ -n "$dest" ]; then
              cd "$dest"
          fi
      }

      dotpush() {
          local current_dir
          current_dir=$(pwd)
          cd ~/dotfiles || return

          git add -A
          if [ -n "$1" ]; then
              git commit -m "$1"
          else
              git commit -m "Update dotfiles"
          fi
          git push

          cd "$current_dir" || return
      }

      if command -v starship >/dev/null 2>&1; then
          eval "$(starship init bash)"
      fi

      if [ -f "$HOME/.bashrc.local" ]; then
          . "$HOME/.bashrc.local"
      fi

      if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
        exec fish
      fi
    '';
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      ls = "eza";
      cat = "bat";
      find = "fd";
      grep = "rg";
      gq = "ghq-cd";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate";
      gp = "git push";
      gpl = "git pull";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      dotfiles-bootstrap = "nix run ~/dotfiles#switch --impure";
      cc = "claude --dangerously-skip-permissions";
    };
    shellAbbrs = {
      cdd = "cd ~/dotfiles";
      cdp = "cd ~/projects";
      gco = "git checkout";
      gcb = "git checkout -b";
      gcm = "git commit -m";
      gca = "git commit --amend";
      grb = "git rebase";
      gst = "git stash";
      gstp = "git stash pop";
      dps = "docker ps";
      dpsa = "docker ps -a";
      di = "docker images";
      dc = "docker compose";
      dcu = "docker compose up";
      dcd = "docker compose down";
      dcl = "docker compose logs";
      update = "sudo apt update && sudo apt upgrade";
      ports = "ss -tuln";
    };
    interactiveShellInit = ''
      set -g fish_greeting
      set -g fish_history_size 10000
      set -gx LSCOLORS GxFxCxDxBxegedabagaced
      set -gx LS_COLORS 'di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

      if type -q starship
          starship init fish | source
      end

      if test -f "$HOME/.config/fish/config.local.fish"
          source "$HOME/.config/fish/config.local.fish"
      end
    '';
    functions = {
      ghq-cd = ''
        set -l dest (ghq list -p | fzf --prompt='ghq> ' --height=40% --reverse)
        if test -n "$dest"
            cd "$dest"
        end
      '';
      dotpush = ''
        set -l current_dir (pwd)
        cd ~/dotfiles

        git add -A

        if test -n "$argv[1]"
            git commit -m "$argv[1]"
        else
            git commit -m "Update dotfiles"
        end

        git push
        cd "$current_dir"
      '';
    };
  };

  home.file.".config/fish/conf.d/env.fish".text = ''
    if test -d "$HOME/.cargo"
        fish_add_path $HOME/.cargo/bin
    end

    if test -d "$HOME/go"
        set -gx GOPATH $HOME/go
        fish_add_path $GOPATH/bin
    end

    if string match -q "*microsoft*" (uname -r)
        set -gx BROWSER wslview
        if test -d "/mnt/c/Users"
            for dir in /mnt/c/Users/*
                if test -d "$dir" -a -d "$dir/Desktop"
                    set -gx WINHOME $dir
                    break
                end
            end
        end
    end
  '';
}
