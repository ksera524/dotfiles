function dotpush --description 'Push dotfiles changes to GitHub'
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
end