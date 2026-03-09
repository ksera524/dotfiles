{ pkgs, ... }:
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

      if [ -f "$HOME/.bashrc.local" ]; then
          . "$HOME/.bashrc.local"
      fi

      if command -v fish >/dev/null 2>&1 && [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
        exec fish
      fi
    '';
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
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

      set -g pure_enable_container_detection false
      set -g pure_enable_virtualenv false
      set -g pure_enable_aws_profile false
      set -g pure_enable_single_line_prompt true

      functions --erase _pure_prompt_git 2>/dev/null

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
      __prompt_git_current_repo = ''
        if set -q __prompt_git_last_lookup_pwd; and test "$__prompt_git_last_lookup_pwd" = "$PWD"
            echo "$__prompt_git_last_lookup_repo"
            return
        end

        set -l repo (command git rev-parse --show-toplevel 2>/dev/null)
        set -g __prompt_git_last_lookup_pwd "$PWD"
        set -g __prompt_git_last_lookup_repo "$repo"
        echo "$repo"
      '';
      __prompt_git_branch_sync = ''
        set -l repo "$argv[1]"
        set -l branch (command git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null)
        if test -z "$branch"
            set branch (command git -C "$repo" rev-parse --short HEAD 2>/dev/null)
        end
        echo "$branch"
      '';
      __prompt_git_collect_async = ''
        if not set -q __prompt_git_refresh_pid; or not set -q __prompt_git_refresh_tmp
            return
        end

        if kill -0 $__prompt_git_refresh_pid >/dev/null 2>&1
            return
        end

        if test -f "$__prompt_git_refresh_tmp"
            set -l payload (command cat "$__prompt_git_refresh_tmp")
            command rm -f "$__prompt_git_refresh_tmp"
            set -l lines (string split \n -- "$payload")
            set -g __prompt_git_cache_repo "$lines[1]"
            set -g __prompt_git_cache_branch "$lines[2]"
        end

        set -e __prompt_git_refresh_pid
        set -e __prompt_git_refresh_tmp
        set -g __prompt_git_last_refresh_tick $__prompt_git_command_tick
      '';
      __prompt_git_request_refresh = ''
        if not status is-interactive
            return
        end

        __prompt_git_collect_async

        set -l repo (__prompt_git_current_repo)
        if test -z "$repo"
            set -e __prompt_git_cache_repo
            set -e __prompt_git_cache_branch
            return
        end

        if set -q __prompt_git_refresh_pid
            return
        end

        set -l force "$argv[1]"
        if not set -q __prompt_git_command_tick
            set -g __prompt_git_command_tick 0
        end

        if test "$force" != force
            if set -q __prompt_git_last_refresh_tick
                set -l delta (math "$__prompt_git_command_tick - $__prompt_git_last_refresh_tick")
                if test $delta -lt 2
                    return
                end
            end
        end

        set -l tmp "/tmp/fish-git-prompt-$fish_pid-"(random)".tmp"
        command fish --no-config -c 'set -l repo $argv[1]; set -l branch (command git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null); if test -z "$branch"; set branch (command git -C "$repo" rev-parse --short HEAD 2>/dev/null); end; printf "%s\n%s\n" "$repo" "$branch"' "$repo" >"$tmp" 2>/dev/null &

        set -g __prompt_git_refresh_pid $last_pid
        set -g __prompt_git_refresh_tmp "$tmp"
      '';
      _pure_prompt_git = ''
        if set --query pure_enable_git; and test "$pure_enable_git" != true
            return
        end

        if not type -q --no-functions git
            return 2
        end

        __prompt_git_collect_async

        set -l repo (__prompt_git_current_repo)
        if test -z "$repo"
            return
        end

        if not set -q __prompt_git_cache_repo; or test "$__prompt_git_cache_repo" != "$repo"
            set -g __prompt_git_cache_repo "$repo"
            set -g __prompt_git_cache_branch (__prompt_git_branch_sync "$repo")
        end

        if test -n "$__prompt_git_cache_branch"
            echo (_pure_set_color $pure_color_git_branch)"$__prompt_git_cache_branch"
        end
      '';
    };
  };

  home.file.".config/fish/conf.d/prompt-git-cache.fish".text = ''
    status is-interactive; or return

    function __prompt_git_postexec_refresh --on-event fish_postexec
        if not set -q __prompt_git_command_tick
            set -g __prompt_git_command_tick 0
        end
        set -g __prompt_git_command_tick (math "$__prompt_git_command_tick + 1")
        __prompt_git_request_refresh
    end

    function __prompt_git_pwd_refresh --on-variable PWD
        __prompt_git_request_refresh force
    end
  '';

  home.file.".config/fish/conf.d/env.fish".text = ''
    status is-interactive; or return

    if status is-login
        if test -d "$HOME/.cargo/bin"
            fish_add_path $HOME/.cargo/bin
        end

        if test -d "$HOME/go/bin"
            set -gx GOPATH $HOME/go
            fish_add_path $HOME/go/bin
        end

        if set -q WSL_DISTRO_NAME
            set -gx BROWSER wslview

            if not set -q WINHOME
                if test -d "/mnt/c/Users/$USER/Desktop"
                    set -gx WINHOME "/mnt/c/Users/$USER"
                end
            end
        end
    end
  '';
}
