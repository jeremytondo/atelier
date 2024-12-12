#!/bin/bash

# Install ZSH
sudo apt install zsh -y

# Make ZSH the default shell
sudo chsh -s $(which zsh) $USER

# Load the PATH for use later in the installers
# source ~/.local/share/omakub/defaults/bash/shell
