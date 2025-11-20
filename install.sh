#!/bin/bash

# Mac Terminal Setup Script
# Prerequisites: Xcode Developer Tools and Homebrew must be installed

set -e # Exit on error

# Get script directory and source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common.sh"

PACKAGES_DIR="$SCRIPT_DIR/packages"

# Update Homebrew
update_homebrew() {
  print_step "Updating Homebrew package lists..."
  brew update
}

# Main installation flow
main() {
  echo "=== Mac Terminal Setup ==="

  update_homebrew
  install_packages "base packages" "$PACKAGES_DIR/base.packages"
  install_packages "development packages" "$PACKAGES_DIR/dev.packages"

  echo "✅ Setup complete! Package lists: $PACKAGES_DIR"
}

# Run main function
main
