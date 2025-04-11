#!/bin/bash

# Define source directory
DOTFILES_DIR="$HOME/.dotfiles"

brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick font-symbols-only-nerd-font
brew install --cask nikitabobko/tap/aerospace

echo "Setting up dotfiles symlinks..."

# Individual dotfile symlinks with force option
ln -sf "$DOTFILES_DIR/.aerospace" "$HOME/.aerospace"
ln -sf "$DOTFILES_DIR/.config/yazi" "$HOME/.config/yazi"

echo "Dotfiles setup complete!"
