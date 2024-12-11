#!/bin/bash

# Install ZSH
sudo apt install zsh -y

# Make ZSH the default shell
chsh -s $(which zsh)

# Load the PATH for use later in the installers
# source ~/.local/share/omakub/defaults/bash/shell
