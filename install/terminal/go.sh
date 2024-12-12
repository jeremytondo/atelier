#!/bin/bash

VERSION="1.23.4"

if ! command -v go &>/dev/null; then
  # https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
  cd /tmp
  echo "https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz"
  curl -sLo go.tar.gz "https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm -rf /tmp/go.tar.gz
  echo "Go has been installed successfully."
  cd -
else
  echo "Go is already installed."
fi
