#!/bin/bash

source "$(dirname "$0")/shared.sh"

if [[ $(uname -s) == "Linux" ]]; then
  as_root apt-get update -y
  as_root apt-get install -y \
        curl \
        git \
        unzip \
        wget \
        stow \
        build-essential \
        fzf \
        ripgrep \
        bat \
        eza \
        zoxide \
        plocate \
        btop \
        apache2-utils \
        fd-find \
        tldr \
        openssh-server \
        sudo \
        ca-certificates \
        ncurses-bin \
        passwd \
        zsh \
        locales \
        gosu
else
  brew install stow fzf ripgrep bat eza zoxide btop tldr fd
  brew install pkg-config autoconf bison libvips
fi
