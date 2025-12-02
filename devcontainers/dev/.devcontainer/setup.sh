#!/bin/bash
set -e

# This script runs as devuser
REPO="https://github.com/jeremytondo/atelier.git"
CLONE_DIR="$HOME/.local/share/atelier"

# This will be passed via ARG/ENV in the Dockerfile
BRANCH="${BRANCH:-dev}"

# Ensure necessary directories exist before cloning
echo "Creating necessary directories..."
mkdir -p "$HOME/.local/share"

echo "Cloning Atelier from $REPO (branch: $BRANCH)..."

git clone -b "$BRANCH" "$REPO" "$CLONE_DIR"
echo "Atelier cloned successfully."

# Clean up existing configs
echo "Removing existing config files to avoid conflicts..."
rm -f "$HOME/.zshrc" "$HOME/.bashrc"

STOW_DIR="$CLONE_DIR/config"
echo "Running stow to link dotfiles from $STOW_DIR..."

cd "$STOW_DIR" && stow --target="$HOME" .

echo "User setup script finished successfully."
