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

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Modern CLI aliases
alias ls='eza'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias gq='ghq-cd'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Dotfiles management aliases
alias dotfiles-bootstrap='cd ~/dotfiles && ./bootstrap.sh'

# Claude Code alias
alias cc='claude --dangerously-skip-permissions'

# Load local configuration if exists
if test -f "$HOME/.config/fish/config.local.fish"
    source "$HOME/.config/fish/config.local.fish"
end
