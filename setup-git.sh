#!/bin/bash
set -e

echo "🔧 Setting up git configuration..."


git config --global user.name "ksera524"
git config --global user.email "ksera631@gmail.com"

git config --global delta.enable true
git config --global delta.line-numbers true
git config --global delta.theme "OneHalfDark"

git config --global alias.co checkout
git config --global alias.br "branch -vv"
git config --global alias.st "status -sb"

git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global core.editor vim

echo "✅ Git configuration completed."
