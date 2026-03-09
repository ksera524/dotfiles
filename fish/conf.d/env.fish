# Environment variables

status is-interactive; or return

# Editor
set -gx EDITOR vim
set -gx VISUAL vim

# Development
set -gx NODE_ENV development

# Python
if test -d "$HOME/.local/bin"
    fish_add_path $HOME/.local/bin
end

if status is-login
    # Rust
    if test -d "$HOME/.cargo/bin"
        fish_add_path $HOME/.cargo/bin
    end

    # Go
    if test -d "$HOME/go/bin"
        set -gx GOPATH $HOME/go
        fish_add_path $HOME/go/bin
    end

    # WSL specific settings
    if set -q WSL_DISTRO_NAME
        set -gx BROWSER wslview

        if not set -q WINHOME
            if test -d "/mnt/c/Users/$USER/Desktop"
                set -gx WINHOME "/mnt/c/Users/$USER"
            end
        end
    end
end
