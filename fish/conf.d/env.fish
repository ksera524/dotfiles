# Environment variables

# Editor
set -gx EDITOR vim
set -gx VISUAL vim

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

# macOS specific settings
if test (uname -s) = "Darwin"
    set -gx BROWSER open
end

# WSL specific settings
if string match -q "*microsoft*" (uname -r)
    set -gx BROWSER wslview

    if test -d "/mnt/c/Users"
        for dir in /mnt/c/Users/*
            if test -d "$dir" -a -d "$dir/Desktop"
                set -gx WINHOME $dir
                break
            end
        end
    end
end
