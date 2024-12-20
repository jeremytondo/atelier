#!/bin/bash

if [[ "$OS" == "Linux" ]]; then
  sudo apt install -y tmux
else
  brew install tmux
fi

# Install Tmux plugin manager.
if ! [[ -d "$SCRIPT_DIR/config/.config/tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm $SCRIPT_DIR/config/.config/tmux/plugins/tpm
fi
