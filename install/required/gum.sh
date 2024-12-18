#!/bin/bash

GUM_VERSION="0.14.3" # Use known good version

if [[ $OS == "Linux" ]]; then
  cd /tmp
  wget -qO gum.deb "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_amd64.deb"
  sudo apt-get install -y ./gum.deb
  rm gum.deb
  cd -
else
  brew install gum
fi
