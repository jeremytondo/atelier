#!/bin/bash

if ! [[ -d "~/.local/share/zsh-autosuggestions" ]]; then
  sudo git clone https://github.com/zsh-users/zsh-autosuggestions ~/.local/share/zsh-autosuggestions/
fi
