#!/bin/bash

# Set the source directory for dotfiles
DOTFILES_DIR="$HOME/.dotfiles"

# --- Brew Installations ---
echo "Installing packages and applications from Brewfile..."
# Navigate to the dotfiles directory to ensure Brewfile is found
# --no-lock prevents the creation of a Brewfile.lock.json
if ! (cd "$DOTFILES_DIR" && brew bundle install --no-lock); then
  echo "Failed to install bundles from Brewfile."
  exit 1
fi

# --- Decrypt Secrets ---
echo "Decrypting secrets..."
if [ -f "$DOTFILES_DIR/key.txt" ] && [ -f "$DOTFILES_DIR/env.secrets.age" ]; then
  age -d -i "$DOTFILES_DIR/key.txt" -o "$DOTFILES_DIR/env.secrets" "$DOTFILES_DIR/env.secrets.age"
  echo "Secrets decrypted."
else
  echo "Warning: key.txt or env.secrets.age not found. Skipping decryption."
  echo "To decrypt secrets, create key.txt with your secret key and run this script again."
fi

# --- Symlinking ---
echo "Setting up dotfiles symlinks..."

# Define symlinks as an associative array for clarity
# format: source_path -> destination_path
declare -A symlinks=(
  ["$DOTFILES_DIR/.aerospace.toml"]="$HOME/.aerospace.toml"
  ["$DOTFILES_DIR/.p10k.zsh"]="$HOME/.p10k.zsh"
  ["$DOTFILES_DIR/.tmux.conf"]="$HOME/.tmux.conf"
  ["$DOTFILES_DIR/.zshrc"]="$HOME/.zshrc"
  ["$DOTFILES_DIR/.config/gemini"]="$HOME/.config/gemini"
  ["$DOTFILES_DIR/.config/nvim"]="$HOME/.config/nvim"
  ["$DOTFILES_DIR/.config/yazi"]="$HOME/.config/yazi"
  ["$DOTFILES_DIR/ghostty"]="$HOME/.config/ghostty"
  ["$DOTFILES_DIR/kitty"]="$HOME/.config/kitty"
  ["$DOTFILES_DIR/tmux"]="$HOME/.tmux"
  ["$DOTFILES_DIR/tmux-sessionizer.conf"]="$HOME/.config/tmux-sessionizer/tmux-sessionizer.conf"
)

# Loop through the associative array to create directories and symlinks
for src in "${!symlinks[@]}"; do
  dest="${symlinks[$src]}"
  dest_dir=$(dirname "$dest")

  # Create destination directory if it doesn't exist
  if [ ! -d "$dest_dir" ]; then
    echo "Creating directory: $dest_dir"
    mkdir -p "$dest_dir"
  fi

  # Create symlink with force option
  echo "Linking $src to $dest"
  ln -sf "$src" "$dest"
done

echo "Dotfiles setup complete!"
