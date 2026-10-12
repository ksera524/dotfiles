fish_add_path --path "$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin

if command -q mise
    if status is-interactive
        mise activate fish | source
    else
        mise env --shell fish | source
    end
end

status is-interactive; or return

set -g fish_greeting
set -g fish_history_size 10000
set -gx LSCOLORS GxFxCxDxBxegedabagaced
set -gx LS_COLORS 'di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

set -g pure_enable_container_detection false
set -g pure_enable_virtualenv false
set -g pure_enable_aws_profile false
set -g pure_enable_single_line_prompt true

abbr --add ll 'ls -alF'
abbr --add la 'ls -A'
abbr --add l 'ls -CF'
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'
abbr --add .... 'cd ../../..'
abbr --add ls eza
abbr --add cat bat
abbr --add find fd
abbr --add grep rg
abbr --add gq ghq-cd
abbr --add gs 'git status'
abbr --add ga 'git add'
abbr --add gc 'git commit'
abbr --add gd 'git diff'
abbr --add gl 'git log --oneline --graph --decorate'
abbr --add gp 'git push'
abbr --add gpl 'git pull'
abbr --add rm 'rm -i'
abbr --add cp 'cp -i'
abbr --add mv 'mv -i'
abbr --add cc 'claude --dangerously-skip-permissions'
abbr --add cx 'codex --yolo'
abbr --add cdp 'cd ~/projects'
abbr --add gco 'git checkout'
abbr --add gcb 'git checkout -b'
abbr --add gcm 'git commit -m'
abbr --add gca 'git commit --amend'
abbr --add grb 'git rebase'
abbr --add gst 'git stash'
abbr --add gstp 'git stash pop'
abbr --add dps 'docker ps'
abbr --add dpsa 'docker ps -a'
abbr --add di 'docker images'
abbr --add dc 'docker compose'
abbr --add dcu 'docker compose up'
abbr --add dcd 'docker compose down'
abbr --add dcl 'docker compose logs'

if test (uname) = Linux
    abbr --add update 'sudo apt update && sudo apt upgrade'
    abbr --add ports 'ss -tuln'
end

if set -q WSL_DISTRO_NAME
    if not set -q WINHOME; and test -d "/mnt/c/Users/$USER/Desktop"
        set -gx WINHOME "/mnt/c/Users/$USER"
    end
end

if test -f "$HOME/.config/fish/config.local.fish"
    source "$HOME/.config/fish/config.local.fish"
end
