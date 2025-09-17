#!/bin/bash
# Fish shell installation script for Ubuntu/WSL

echo "🐠 Installing Fish shell..."

# Check if running with sudo capabilities
if [ "$EUID" -eq 0 ]; then
   echo "Please don't run this script as root"
   exit 1
fi

# Update package list
echo "📦 Updating package list..."
sudo apt-get update

# Install fish
echo "🐠 Installing fish package..."
sudo apt-get install -y fish

if [ $? -eq 0 ]; then
    echo "✅ Fish installed successfully!"

    # Create config directory and symlinks
    echo "🔗 Setting up fish configuration..."
    mkdir -p ~/.config/fish
    ln -sf ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
    ln -sf ~/dotfiles/fish/functions ~/.config/fish/functions
    ln -sf ~/dotfiles/fish/conf.d ~/.config/fish/conf.d
    echo "✓ Fish configuration linked"

    # Add fish to valid shells
    FISH_PATH=$(which fish)
    echo "Found fish at: $FISH_PATH"

    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "Adding fish to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells
        echo "✓ Fish added to valid shells"
    else
        echo "✓ Fish already in valid shells"
    fi

    # Change default shell
    echo ""
    echo "🔄 Changing default shell to fish..."
    chsh -s "$FISH_PATH"

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Fish is now your default shell!"
        echo "⚠️  IMPORTANT: Log out and log back in for changes to take effect."
        echo ""
        echo "Or you can start fish right now by typing: fish"
    else
        echo "❌ Failed to set fish as default shell"
        echo "You can try manually with: chsh -s $(which fish)"
    fi
else
    echo "❌ Failed to install fish"
    exit 1
fi