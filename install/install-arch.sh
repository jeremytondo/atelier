#!/bin/bash

# Arch Linux Terminal Setup Script
# Prerequisites: Arch Linux with base-devel group installed

set -e # Exit on error

# Get script directory and source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PACKAGES_DIR="$(dirname "$SCRIPT_DIR")/packages"

# Check if we're on Arch Linux
check_arch_linux() {
  if [ ! -f /etc/arch-release ]; then
    print_error "This script is designed for Arch Linux"
    exit 1
  fi
}

# Update system packages
update_system() {
  print_step "Updating system packages..."
  sudo pacman -Sy --noconfirm
}

# Install paru AUR helper if not present
install_paru() {
  if ! check_command paru; then
    print_step "Installing paru AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel
    
    local tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmp_dir/paru"
    
    pushd "$tmp_dir/paru" > /dev/null
    makepkg -si --noconfirm
    popd > /dev/null
    
    rm -rf "$tmp_dir"
  fi
}

# Install packages from a package file for Arch
install_packages_from_file() {
  local category="$1"
  local file="$2"
  local platform="arch"
  
  print_step "Installing $category..."

  local packages=$(read_packages_for_platform "$file" "$platform")
  if [ -z "$packages" ]; then
    print_warning "No packages found for $platform in $file"
    return
  fi

  # Install all packages using paru
  print_info "Installing packages:$packages"
  paru -S --needed --noconfirm $packages
}

# Main installation flow
main() {
  echo "=== Arch Linux Terminal Setup ==="
  
  check_arch_linux
  update_system
  install_paru
  install_packages_from_file "base packages" "$PACKAGES_DIR/base.packages"
  install_packages_from_file "development packages" "$PACKAGES_DIR/dev.packages"
  
  echo "✅ Setup complete! Package lists: $PACKAGES_DIR"
}

# Run main function
main