#!/bin/bash

source "$(dirname "$0")/../shared.sh"

if [[ $(uname -s) == "Linux" ]]; then
  cd /tmp
  echo "INFO: Downloading Neovim..."
  wget -O nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-arm64.tar.gz"
  
  echo "INFO: Extracting archive..."
  tar -xf nvim.tar.gz
  
  echo "INFO: Installing Neovim..."
  as_root cp -r nvim-linux64/* /usr/local/
  
  echo "INFO: Cleaning up..."
  rm -rf nvim-linux64 nvim.tar.gz
  
  echo "INFO: Verifying installation..."
  if ! command -v nvim >/dev/null 2>&1; then
    echo "ERROR: nvim not found in PATH"
    exit 1
  fi
  
  nvim --version || exit 1
  cd -
else
  brew install neovim
fi