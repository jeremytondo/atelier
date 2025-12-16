#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

print_step "Installing shpool..."

if check_command yay; then
  yay -S --noconfirm --needed --nocheck shpool

  print_info "Configuring systemd services for shpool..."
  systemctl --user enable shpool
  systemctl --user start shpool

  # Enable linger for the current user so services run without an active session
  sudo loginctl enable-linger "$USER"
else
  print_warning "yay not found. Skipping shpool installation (likely non-Arch platform)."
fi
