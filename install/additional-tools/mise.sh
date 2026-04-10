#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

print_step "Installing mise..."

if check_command mise; then
  print_info "mise is already installed: $(mise --version)"
  exit 0
fi

install_via_official_script() {
  print_info "Installing mise via the official installer..."
  curl https://mise.run | sh
}

case "$(uname -s)" in
  Darwin)
    install_via_official_script
    ;;
  Linux)
    if [ -f /etc/arch-release ]; then
      install_via_official_script
    else
      print_warning "Non-Arch Linux detected. Falling back to the official mise installer."
      install_via_official_script
    fi
    ;;
  *)
    print_error "Unsupported platform: $(uname -s)"
    exit 1
    ;;
esac

if check_command mise; then
  print_info "mise installed successfully: $(mise --version)"
elif [ -x "$HOME/.local/bin/mise" ]; then
  print_info "mise installed successfully: $("$HOME/.local/bin/mise" --version)"
else
  print_error "mise installation completed, but the binary was not found on PATH or at ~/.local/bin/mise"
  exit 1
fi
