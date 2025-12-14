#!/bin/bash

# Main Install Script
# Dispatches to platform-specific installers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

# Function to run mac installer
run_mac() {
  echo "Detected/Selected macOS."
  bash "$INSTALL_DIR/install-mac.sh"
}

# Function to run arch installer
run_arch() {
  echo "Detected/Selected Arch Linux."
  bash "$INSTALL_DIR/install-arch.sh"
}

# Main logic
detect_platform() {
  if [ "$(uname -s)" == "Darwin" ]; then
    run_mac
  elif [ -f /etc/arch-release ]; then
    run_arch
  else
    echo "Error: Could not detect compatible platform (macOS or Arch Linux)."
    echo "Usage: ./install.sh [mac|arch]"
    exit 1
  fi
}

if [ "$1" == "mac" ]; then
  run_mac
elif [ "$1" == "arch" ]; then
  run_arch
elif [ -z "$1" ]; then
  detect_platform
else
  echo "Error: Invalid argument '$1'."
  echo "Usage: ./install.sh [mac|arch]"
  exit 1
fi
