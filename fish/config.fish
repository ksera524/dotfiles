# Fish Shell Configuration

# Remove fish greeting
set -g fish_greeting

# History settings
set -g fish_history_size 10000

status is-interactive; or return

# Pure prompt performance tuning
set -g pure_enable_container_detection false
set -g pure_enable_virtualenv false
set -g pure_enable_aws_profile false
set -g pure_enable_single_line_prompt true

functions --erase _pure_prompt_git 2>/dev/null

# Color settings for ls
set -gx LSCOLORS GxFxCxDxBxegedabagaced
set -gx LS_COLORS 'di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Prefer abbreviations over aliases for startup speed
abbr --add --global ll 'ls -alF'
abbr --add --global la 'ls -A'
abbr --add --global l 'ls -CF'
abbr --add --global .. 'cd ..'
abbr --add --global ... 'cd ../..'
abbr --add --global .... 'cd ../../..'

abbr --add --global ls 'eza'
abbr --add --global cat 'bat'
abbr --add --global find 'fd'
abbr --add --global grep 'rg'
abbr --add --global gq 'ghq-cd'

abbr --add --global gs 'git status'
abbr --add --global ga 'git add'
abbr --add --global gc 'git commit'
abbr --add --global gd 'git diff'
abbr --add --global gl 'git log --oneline --graph --decorate'
abbr --add --global gp 'git push'
abbr --add --global gpl 'git pull'

abbr --add --global rm 'rm -i'
abbr --add --global cp 'cp -i'
abbr --add --global mv 'mv -i'

abbr --add --global dotfiles-bootstrap 'cd ~/dotfiles && ./bootstrap.sh'
abbr --add --global cc 'claude --dangerously-skip-permissions'

# Load local configuration if exists
if test -f "$HOME/.config/fish/config.local.fish"
    source "$HOME/.config/fish/config.local.fish"
end
