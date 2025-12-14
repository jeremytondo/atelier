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
