#!/bin/bash

source "$(dirname "$0")/../shared.sh"

if ! [[ -d "/usr/local/share/zsh-autosuggestions" ]]; then
  as_root mkdir -p /usr/local/share
  as_root git clone https://github.com/zsh-users/zsh-autosuggestions /usr/local/share/zsh-autosuggestions/
fi
