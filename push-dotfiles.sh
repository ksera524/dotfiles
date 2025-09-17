#!/bin/bash
set -e

# Save current directory
CURRENT_DIR=$(pwd)

# Navigate to dotfiles
cd ~/dotfiles

# Git operations
echo "📦 Checking dotfiles changes..."
if [[ -n $(git status -s) ]]; then
    git add -A
    echo "📝 Changes found:"
    git status --short

    # Commit with custom message or default
    COMMIT_MSG="${1:-Update dotfiles}"
    git commit -m "$COMMIT_MSG"

    echo "⬆️ Pushing to GitHub..."
    git push origin main
    echo "✅ Dotfiles pushed successfully!"
else
    echo "✨ No changes to push"
fi

# Return to original directory
cd "$CURRENT_DIR"