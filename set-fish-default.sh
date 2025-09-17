#!/bin/bash

echo "🐠 Setting Fish as default shell..."

# Check if fish is installed
if ! command -v fish &> /dev/null; then
    echo "❌ Fish is not installed."
    echo "Please run: sudo apt update && sudo apt install -y fish"
    exit 1
fi

FISH_PATH=$(which fish)
echo "Found fish at: $FISH_PATH"

# Check if fish is in /etc/shells
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "Adding fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
    echo "✓ Fish added to valid shells"
else
    echo "✓ Fish already in valid shells"
fi

# Change default shell
echo "Changing default shell to fish..."
chsh -s "$FISH_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Successfully set fish as default shell!"
    echo ""
    echo "⚠️  IMPORTANT: You need to log out and log back in for the change to take effect."
    echo ""
    echo "After logging back in, your default shell will be fish."
    echo "Current shell: $SHELL"
    echo "New shell will be: $FISH_PATH"
else
    echo "❌ Failed to change shell. You may need to run this script with appropriate permissions."
fi