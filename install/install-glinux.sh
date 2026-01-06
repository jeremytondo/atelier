#!/bin/bash

# gLinux/Ubuntu Terminal Setup Script

set -e # Exit on error

# Get script directory and source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Update system packages
update_system() {
  print_step "Updating system packages..."
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
}

# Install base packages matching Dockerfile
install_base_tools() {
  print_step "Installing base tools..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    stow \
    zoxide \
    ripgrep \
    bat \
    fd-find \
    fzf \
    eza \
    git
}

# Install Zsh plugins
install_zsh_plugins() {
  print_step "Installing zsh plugins..."
  if [ ! -d "/usr/local/share/zsh-autosuggestions" ]; then
    print_info "Cloning zsh-autosuggestions..."
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/local/share/zsh-autosuggestions
  else
    print_info "zsh-autosuggestions already installed"
  fi
}

# Setup Symlinks for Ubuntu/Debian naming quirks
# setup_symlinks() {
#   print_step "Setting up symlinks..."
#   # bat -> batcat
#   if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
#     print_info "Linking bat -> batcat"
#     sudo ln -s $(which batcat) /usr/local/bin/bat
#   fi
#
#   # fd -> fdfind
#   if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
#     print_info "Linking fd -> fdfind"
#     sudo ln -s $(which fdfind) /usr/local/bin/fd
#   fi
# }

# Main execution
update_system
install_base_tools
install_zsh_plugins

# Install dotfiles
bash "$SCRIPT_DIR/dotfiles.sh"

# Install NVM
bash "$SCRIPT_DIR/nvm.sh"

print_step "gLinux setup complete!"

