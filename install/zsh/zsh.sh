#!/bin/bash

# Backup existing bash config.
mkdir ~/.bash.bak

if [[ -f "~/.bashrc" ]]; then
  mv ~/.bashrc ~/.bash.bak
fi

if [[ -f "~/.profile" ]]; then
  mv ~/.profile ~/.bash.bak
fi

if [[ -f "~/.bash_logout" ]]; then
  mv ~/.bash_logout ~/.bash.bak
fi

if [[ -f "~/.bash_history" ]]; then
  mv ~/.bash_history ~/.bash.bak
fi

# Install ZSH
sudo apt install zsh -y

# Make ZSH the default shell
sudo chsh -s $(which zsh) $USER
