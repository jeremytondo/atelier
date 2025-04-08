#!/bin/bash

source "$(dirname "$0")/../shared.sh"

if [[ "$OS" == "Linux" ]]; then
  cd /tmp
  wget -O nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
  tar -xf nvim.tar.gz
  as_root install nvim-linux64/bin/nvim /usr/local/bin/nvim
  as_root cp -R nvim-linux64/lib /usr/local/
  as_root cp -R nvim-linux64/share /usr/local/
  rm -rf nvim-linux64 nvim.tar.gz
  cd -
else
  brew install neovim
fi