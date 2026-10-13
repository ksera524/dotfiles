function cdd
    set -l dir (__dotfiles_dir)
    or return
    cd "$dir"
end
