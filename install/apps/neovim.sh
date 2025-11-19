#!/bin/bash

source "$(dirname "$0")/install/shared.sh"

if [[ $(uname -s) == "Linux" ]]; then
  cd /tmp
  echo "INFO: Downloading Neovim..."
  wget -O nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

  # curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  # sudo rm -rf /opt/nvim
  # sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

  echo "INFO: Extracting archive..."
  tar -xf nvim.tar.gz

  echo "INFO: Installing Neovim..."
  as_root cp -r nvim-linux-x86_64/* /usr/local/

  echo "INFO: Cleaning up..."
  rm -rf nvim-linux-linux-x86_64 nvim.tar.gz
else
  brew install neovim
fi
