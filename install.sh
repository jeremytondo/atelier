#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Directory the install.sh file is in at the time it is run.
# SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
SCRIPT_DIR=$HOME/.local/share/atelier

# OS type: Linux or Darwin (MacOS)
OS="$(uname -s)"

# Installs required apps needed for the rest of the install process.
for app in $SCRIPT_DIR/install/required/*.sh; do source $app; done

# Backup existing configs.
createBackups() {
  rm -rf "$HOME/.config.bak"
  rm -rf "$HOME/.bash.bak"

  # If there is an existng zsh config, back it up.
  [ -f "$HOME/.zshrc" ] && mv ~/.zshrc ~/config.bak

  # If there is an existing .config directlry, back it up.
  if [[ -d "$HOME/.config" ]]; then
    mv ~/.config ~/config.bak
  fi
}
confirm_message="This script will replace the folders ~/.config.bak and ~/.bash.bak. Are you sure you want to do this?"
gum confirm "$confirm_message" && createBackups || echo "Not gonna do it"

if [[ "$OS" == "Linux" ]]; then
  # Ensure everything is update before beginning installation.
  sudo apt update -y
  sudo apt upgrade -y
fi

# If zsh is not installed, install it.
if ! command -v zsh &>/dev/null; then
  source $SCRIPT_DIR/install/zsh/zsh.sh
fi

# Install apps.
for app in $SCRIPT_DIR/install/apps/*.sh; do source $app; done

# INSTALL CONFIGS

# Use GNU Stow to to link configs to home directory.
stow . -d $SCRIPT_DIR/config -t ~/

# Install global programmig languages witn mise.
mise use --global node@lts
mise use --global go@latest
