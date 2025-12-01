#!/bin/bash
set -e

# ----------- #
#  Locale Fix #
# ----------- #
# Update the package list
sudo apt-get update
# Install the locales package
sudo apt-get install -y locales
# Generate the en_US.UTF-8 locale
sudo sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen

# ------------------------- #
# Install Atelier Dotfiles  #
# ------------------------- #
REPO="https://github.com/jeremytondo/atelier.git"
CLONE_DIR="$HOME/.local/share/atelier"

# Use the environment variable from devcontainer.json, or default to "main" if not set.
BRANCH="${BRANCH:-main}"

echo "Cloning Atelier from $REPO (branch: $BRANCH)..."

if [ -d "$CLONE_DIR" ]; then
  echo "Atelier directory already exists. Pulling latest changes."
  cd "$CLONE_DIR"
  git pull
else
  git clone -b "$BRANCH" "$REPO" "$CLONE_DIR"
  echo "Atelier cloned successfully."
fi

# Clean up existing configs
echo "Removing existing config files to avoid conflicts..."
rm -f "$HOME/.zshrc" "$HOME/.bashrc"

STOW_DIR="$CLONE_DIR/config"
echo "Running stow to link dotfiles from $STOW_DIR..."

# The -t flag sets the target directory for the symlinks to $HOME.
# The . tells stow to process all packages in the current directory.
cd "$STOW_DIR" && stow --target="$HOME" .

echo "Post-create setup script finished successfully."
