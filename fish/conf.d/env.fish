# Environment variables

# Editor
set -gx EDITOR vim
set -gx VISUAL vim

# Language settings
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Development
set -gx NODE_ENV development

# Rust
if test -d "$HOME/.cargo"
    fish_add_path $HOME/.cargo/bin
end

# Go
if test -d "$HOME/go"
    set -gx GOPATH $HOME/go
    fish_add_path $GOPATH/bin
end

# Python
if test -d "$HOME/.local/bin"
    fish_add_path $HOME/.local/bin
end

# WSL specific settings
if string match -q "*microsoft*" (uname -r)
    # WSL specific environment variables
    set -gx BROWSER wslview

    # Windows home directory - simplified without cmd.exe call
    if test -d "/mnt/c/Users"
        # Try to find Windows user directory without calling cmd.exe
        for dir in /mnt/c/Users/*
            if test -d "$dir" -a -d "$dir/Desktop"
                set -gx WINHOME $dir
                break
            end
        end
    end
end