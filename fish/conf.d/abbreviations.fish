# Fish abbreviations (expand on space/enter)
if status is-interactive
    # Navigation
    abbr --add --global cdd 'cd ~/dotfiles'
    abbr --add --global cdp 'cd ~/projects'

    # Git shortcuts
    abbr --add --global gco 'git checkout'
    abbr --add --global gcb 'git checkout -b'
    abbr --add --global gcm 'git commit -m'
    abbr --add --global gca 'git commit --amend'
    abbr --add --global grb 'git rebase'
    abbr --add --global gst 'git stash'
    abbr --add --global gstp 'git stash pop'

    # Docker shortcuts
    abbr --add --global dps 'docker ps'
    abbr --add --global dpsa 'docker ps -a'
    abbr --add --global di 'docker images'
    abbr --add --global dc 'docker compose'
    abbr --add --global dcu 'docker compose up'
    abbr --add --global dcd 'docker compose down'
    abbr --add --global dcl 'docker compose logs'

    # System
    abbr --add --global update 'sudo apt update && sudo apt upgrade'
    abbr --add --global ports 'ss -tuln'
end