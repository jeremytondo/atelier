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

# Install yay AUR helper if not present
install_yay() {
  if ! check_command yay; then
    print_step "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd - > /dev/null
    rm -rf /tmp/yay
  fi
}

# Check if package should be installed from AUR
is_aur_package() {
  local pkg="$1"
  case "$pkg" in
    "lazydocker") return 0 ;;
    *) return 1 ;;
  esac
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

  # Separate AUR vs official packages
  local pacman_packages=""
  local aur_packages=""

  for pkg in $packages; do
    if is_aur_package "$pkg"; then
      aur_packages="$aur_packages $pkg"
    else
      pacman_packages="$pacman_packages $pkg"
    fi
  done

  # Install with appropriate package managers
  if [ -n "$pacman_packages" ]; then
    print_info "Installing official packages:$pacman_packages"
    sudo pacman -S --needed --noconfirm $pacman_packages
  fi
  
  if [ -n "$aur_packages" ]; then
    print_info "Installing AUR packages:$aur_packages"
    yay -S --needed --noconfirm $aur_packages
  fi
}

# Main installation flow
main() {
  echo "=== Arch Linux Terminal Setup ==="
  
  check_arch_linux
  update_system
  install_yay
  install_packages_from_file "base packages" "$PACKAGES_DIR/base.packages"
  install_packages_from_file "development packages" "$PACKAGES_DIR/dev.packages"
  
  echo "✅ Setup complete! Package lists: $PACKAGES_DIR"
}

# Run main function
main