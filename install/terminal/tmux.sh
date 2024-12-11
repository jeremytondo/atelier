#!/bin/bash

sudo app install -y tmux

# Install Tmux plugin manager.
git clone https://github.com/tmux-plugins/tpm $SCRIPT_DIR/config/.config/tmux/plugins/tpm
