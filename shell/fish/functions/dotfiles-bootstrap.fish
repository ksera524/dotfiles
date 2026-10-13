function dotfiles-bootstrap
    set -l dir (__dotfiles_dir)
    or return
    mise -C "$dir" bootstrap $argv
end
