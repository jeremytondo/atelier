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
  sudo pacman -Syu --noconfirm
}

# Install yay AUR helper if not present
install_yay() {
  if ! check_command yay; then
    print_step "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel

    local tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"

    pushd "$tmp_dir/yay" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null

    rm -rf "$tmp_dir"
  fi
}

# Configure Zsh as default shell
setup_shell() {
  print_step "Configuring Zsh..."
  yay -S --needed --noconfirm zsh

  local zsh_path=$(which zsh)
  local current_shell=$(getent passwd "$USER" | cut -d: -f7)

  if [ "$current_shell" != "$zsh_path" ]; then
    print_info "Changing default shell to zsh ($zsh_path)..."
    # Use sudo usermod to avoid authentication token errors common in some environments
    sudo usermod -s "$zsh_path" "$USER"
  else
    print_info "Default shell is already zsh."
  fi
}

# Install packages from a package file for Arch
install_packages_from_file() {
  local file="$1"
  local platform="arch"

  print_step "Installing packages from $(basename "$file")..."

  local packages=$(read_packages_for_platform "$file" "$platform")
  if [ -z "$packages" ]; then
    print_warning "No packages found for $platform in $file"
    return
  fi

  # Install all packages using yay
  print_info "Installing packages:$packages"
  yay -S --needed --noconfirm $packages
}

# Main installation flow
main() {
  echo "=== Arch Linux Terminal Setup ==="

  check_arch_linux
  update_system
  install_yay
  setup_shell

  # Install packages
  install_packages_from_file "$PACKAGES_DIR/base.packages"
  install_packages_from_file "$PACKAGES_DIR/dev.packages"

  # Install additional tools
  bash "$SCRIPT_DIR/additional-tools/all.sh"

  echo "✅ Setup complete! Package lists: $PACKAGES_DIR"
}

# Run main function
main
