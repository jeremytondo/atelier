#!/bin/bash

# Backup existing bash config.
mkdir ~/.bash.bak
mv ~/.bashrc ~/.bash.bak
mv ~/.profile ~/.bash.bak
mv ~/.bash_logout ~/.bash.bak
mv ~/.bash_history ~/.bash.bak

# Install ZSH
sudo apt install zsh -y

# Make ZSH the default shell
sudo chsh -s $(which zsh) $USER

# Load the PATH for use later in the installers
# source ~/.zshrc
