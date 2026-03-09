function ghq-cd --description 'Select and cd into ghq repo'
    set -l dest (ghq list -p | fzf --prompt='ghq> ' --height=40% --reverse)
    if test -n "$dest"
        cd "$dest"
    end
end
