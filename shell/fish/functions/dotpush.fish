function dotpush
    set -l dir (__dotfiles_dir)
    or return
    mise -C "$dir" run --skip-tools dotpush -- $argv
end
