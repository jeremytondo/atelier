#!/bin/bash

# Mac Terminal Setup Script
# Prerequisites: Xcode Developer Tools and Homebrew must be installed

set -e # Exit on error

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/packages"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
  echo -e "${GREEN}==>${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

# Read packages from file and return as space-separated list
read_packages() {
  local file="$1"
  if [ ! -f "$file" ]; then
    print_error "Package file not found: $file"
    return 1
  fi
  # Read file, remove comments and empty lines, join with spaces
  grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' '
}

# Update Homebrew
update_homebrew() {
  print_step "Updating Homebrew package lists..."
  brew update
}

# Install packages from a given file
install_packages() {
  local category="$1"
  local file="$2"
  print_step "Installing $category..."

  local packages=$(read_packages "$file")
  [ -n "$packages" ] && brew install $packages
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
