#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

print_step "Installing zsh-autosuggestions..."

TARGET_DIR="/usr/local/share/zsh-autosuggestions"

if [ -d "$TARGET_DIR" ]; then
  print_info "zsh-autosuggestions already installed at $TARGET_DIR"
else
  # Ensure parent directory exists (though /usr/local/share usually exists)
  if [ ! -d "/usr/local/share" ]; then
      sudo mkdir -p "/usr/local/share"
  fi
  
  sudo git clone https://github.com/zsh-users/zsh-autosuggestions "$TARGET_DIR"
fi
