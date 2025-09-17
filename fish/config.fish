# Fish Shell Configuration

# Remove fish greeting
set -g fish_greeting

# History settings
set -g fish_history_size 10000

# Color settings for ls
set -gx LSCOLORS GxFxCxDxBxegedabagaced
set -gx LS_COLORS 'di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Basic PATH setup
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/share/mise/shims

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

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
alias dotfiles-install='cd ~/dotfiles && bash install.sh'
alias dotfiles-update='cd ~/dotfiles && bash update-tools.sh'
alias dotfiles-vscode='cd ~/dotfiles && bash apply-vscode-config.sh'
alias dotfiles-git='cd ~/dotfiles && bash setup-git.sh'
alias dotfiles-bootstrap='bash <(curl -fsSL https://raw.githubusercontent.com/ksera524/dotfiles/main/bootstrap.sh)'
alias mise-status='mise list --current'

# Claude Code alias
alias cc='claude --dangerously-skip-permissions'

# Initialize mise if available
if test -f "$HOME/.local/bin/mise"
    $HOME/.local/bin/mise activate fish | source
end

# Initialize starship prompt
if type -q starship
    starship init fish | source
end

# Load local configuration if exists
if test -f "$HOME/.config/fish/config.local.fish"
    source "$HOME/.config/fish/config.local.fish"
end