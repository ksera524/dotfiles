#!/bin/bash

echo "🐠 Setting up Fish shell..."

# Check if fish is installed
if ! command -v fish &> /dev/null; then
    echo "❌ Fish is not installed. Installing now..."
    sudo apt update
    sudo apt install -y fish
fi

# Create config directory
mkdir -p ~/.config/fish

# Link fish configuration
echo "🔗 Linking fish configuration..."
ln -sf "$HOME/dotfiles/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sf "$HOME/dotfiles/fish/functions" "$HOME/.config/fish/functions"
ln -sf "$HOME/dotfiles/fish/conf.d" "$HOME/.config/fish/conf.d"

echo "✅ Fish configuration linked!"

# Ask if user wants to set fish as default shell
read -p "Would you like to set fish as your default shell? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if grep -q "$(which fish)" /etc/shells; then
        chsh -s $(which fish)
        echo "✅ Fish set as default shell. Please log out and back in for changes to take effect."
    else
        echo "Adding fish to /etc/shells..."
        echo $(which fish) | sudo tee -a /etc/shells
        chsh -s $(which fish)
        echo "✅ Fish set as default shell. Please log out and back in for changes to take effect."
    fi
else
    echo "ℹ️  You can start fish by running: fish"
    echo "   To set it as default later, run: chsh -s $(which fish)"
fi

echo ""
echo "🎉 Fish setup complete!"
echo "   Start fish now: fish"
echo "   View fish configuration: cat ~/.config/fish/config.fish"