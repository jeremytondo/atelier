#!/bin/bash

# Some general utility apps needed during the install process.

if [[ $OS == "Linux" ]]; then
  sudo apt install -y curl git unzip stow
else
  brew instal stow -y
fi
