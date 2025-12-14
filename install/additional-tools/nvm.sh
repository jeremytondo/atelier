#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

print_step "Installing nvm (Node Version Manager)..."

export NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
  print_info "nvm is already installed in $NVM_DIR"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
fi

# Load nvm to use it in this script
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
  
  print_info "Installing stable node version..."
  nvm install stable
else
  print_error "Could not load nvm from $NVM_DIR/nvm.sh"
fi
