function __dotfiles_dir
    set -l dir "$HOME/.config/mise/conf.d/dotfiles"
    if set -q DOTFILES_DIR; and test -n "$DOTFILES_DIR"
        set dir "$DOTFILES_DIR"
    else if not test -f "$dir/mise.toml"
        set dir "$HOME/src/github.com/ksera524/dotfiles"
    end
    if not test -d "$dir"
        printf 'Error: DOTFILES_DIR does not exist: %s\n' "$dir" >&2
        return 1
    end
    if not test -f "$dir/mise.toml"
        printf 'Error: DOTFILES_DIR has no mise.toml: %s\n' "$dir" >&2
        return 1
    end
    printf '%s\n' "$dir"
end
