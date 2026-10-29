status is-interactive; or return

set -g fish_greeting
set -g fish_history_size 10000

set -g pure_enable_container_detection false
set -g pure_enable_virtualenv false
set -g pure_enable_aws_profile false
set -g pure_enable_single_line_prompt true

abbr --add gq ghq-cd
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
