#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

print_step "Linking dotfiles..."

# Check for stow
if ! check_command stow; then
  print_warning "Stow not found. Please install before running this script."
  exit 1
fi

# Ensure config directory exists
if [ ! -d "$REPO_ROOT/config" ]; then
  print_error "Config directory not found at $REPO_ROOT/config"
  exit 1
fi

# Handle existing .config backup logic
if [ -e "$HOME/.config" ]; then
  print_warning "Found existing $HOME/.config. Backing up to $HOME/.config.bak..."

  if [ -e "$HOME/.config.bak" ]; then
    print_error "Backup destination $HOME/.config.bak already exists. Cannot safely backup existing config. Aborting."
    exit 1
  fi

  mv "$HOME/.config" "$HOME/.config.bak"
fi

# Run stow
# We treat 'config' as the package name, located in REPO_ROOT
print_info "Stowing 'config' package from $REPO_ROOT to $HOME..."
stow --dotfiles -d "$REPO_ROOT" -t "$HOME" config --verbose 1

print_step "Dotfiles linked successfully."
