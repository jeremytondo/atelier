#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

print_step "Linking dotfiles..."

# Check for stow
if ! check_command stow; then
  print_warning "stow not found. Attempting to install..."
  if check_command yay; then
    yay -S --needed --noconfirm stow
  elif check_command brew; then
    brew install stow
  elif check_command apt-get; then
    sudo apt-get install -y stow
  else
    print_error "Please install GNU Stow manually."
    exit 1
  fi
fi

# Ensure config directory exists
if [ ! -d "$REPO_ROOT/config" ]; then
  print_error "Config directory not found at $REPO_ROOT/config"
  exit 1
fi

# Run stow
# We treat 'config' as the package name, located in REPO_ROOT
print_info "Stowing 'config' package from $REPO_ROOT to $HOME..."
stow -d "$REPO_ROOT" -t "$HOME" config --verbose 1

print_step "Dotfiles linked successfully."
