#!/bin/bash

# Install ZSH
sudo apt install zsh -y

# Make ZSH the default shell
chsh -s $(which zsh)
