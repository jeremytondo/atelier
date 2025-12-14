#!/bin/bash

# Mac Terminal Setup Script
# Prerequisites: Xcode Developer Tools and Homebrew must be installed

set -e # Exit on error

# Get script directory and source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PACKAGES_DIR="$(dirname "$SCRIPT_DIR")/packages"

# Update Homebrew
update_homebrew() {
  print_step "Updating Homebrew package lists..."
  brew update
}

# Install packages from a given file using brew for Mac
install_packages_mac() {
  local category="$1"
  local file="$2"
  local platform="mac"
  
  print_step "Installing $category..."

  local packages=$(read_packages_for_platform "$file" "$platform")
  if [ -z "$packages" ]; then
    print_warning "No packages found for $platform in $file"
    return
  fi
  
  brew install $packages
}

# Main installation flow
main() {
  echo "=== Mac Terminal Setup ==="

  update_homebrew
  install_packages_mac "base packages" "$PACKAGES_DIR/base.packages"
  install_packages_mac "development packages" "$PACKAGES_DIR/dev.packages"

  echo "✅ Setup complete! Package lists: $PACKAGES_DIR"
}

# Run main function
main
