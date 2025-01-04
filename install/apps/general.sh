#!/bin/bash

# A general default set of apps that make working in the terninal easier.

if [[ "$OS" == "Linux" ]]; then
  sudo apt install -y fzf ripgrep bat eza zoxide plocate btop apache2-utils fd-find tldr

  # Libraries needed for various things.
  sudo apt install -y \
    build-essential pkg-config autoconf bison clang rustc \
    libssl-dev libreadline-dev zlib1g-dev libyaml-dev libreadline-dev libffi-dev libgdbm-dev libjemalloc2 \
    libvips imagemagick libmagickwand-dev gir1.2-gtop-2.0 gir1.2-clutter-1.0 \
    libpq-dev
else
  brew install fzf ripgrep bat eza zoxide btop tldr

  brew install pkg-config autoconf bison libvips imagemagick mupdf sqlite3
fi
