function dotpush
    set -l dir (__dotfiles_dir)
    or return
    git -C "$dir" add -A
    or return
    if git -C "$dir" diff --cached --quiet
        printf 'No dotfiles changes to push.\n'
        return 0
    end
    set -l message 'Update dotfiles'
    if test -n "$argv[1]"
        set message "$argv[1]"
    end
    git -C "$dir" commit -m "$message"
    or return
    git -C "$dir" push
end
