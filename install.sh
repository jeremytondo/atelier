#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Directory the install.sh file is in at the time it is run.
# SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
SCRIPT_DIR=$HOME/.local/share/atelier

# OS type: Linux or Darwin (MacOS)
OS="$(uname -s)"

# Includes some shared scripts needed for the install process.
source $SCRIPT_DIR/bin/scripts/shared.sh

if [[ "$OS" == "Linux" ]]; then
  echo "Linux"
  # Ensure everything is update before beginning installation.
  sudo apt update -y
  sudo apt upgrade -y
fi

# Installs required apps needed for the rest of the install process.
for app in $SCRIPT_DIR/install/required/*.sh; do source $app; done

# Install ZSH on Linux.
if [[ "$OS" == "Linux" ]]; then
  source $SCRIPT_DIR/install/zsh/zsh.sh
fi

# Install apps.
for app in $SCRIPT_DIR/install/apps/*.sh; do source $app; done

# INSTALL CONFIGS

# Backup existing configs.
mkdir ~/config.bak
[ -f "~/.zshrc" ] && mv ~/.zshrc ~/config.bak

if [[ -d "~/.config" ]]; then
  mv ~/.config ~/config.bak
fi

# Use GNU Stow to to link configs to home directory.
stow . -d $SCRIPT_DIR/config -t ~/

# Install global programmig languages witn mise.
mise use --global node@lts
mise use --global go@latest
