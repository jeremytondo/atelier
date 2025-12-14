#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

print_step "Installing Docker..."

if check_command paru; then
  print_info "Installing docker package..."
  paru -S --noconfirm --needed docker
  
  print_info "Installing docker-buildx..."
  paru -S --noconfirm --needed docker-buildx

  print_info "Enabling and starting docker.socket..."
  sudo systemctl enable --now docker.socket

  print_info "Adding user $USER to docker group..."
  sudo usermod -aG docker "$USER"
  
  print_info "Docker installation complete. You may need to log out and back in for group changes to take effect."
else
  print_warning "paru not found. Skipping Docker installation (likely non-Arch platform)."
fi
