#!/bin/bash

source "$(dirname "$0")/../shared.sh"

if [[ $(uname -s) == "Linux" ]]; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | as_root dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
    as_root chmod go+r /
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    as_root apt update &&
    as_root apt install gh -y
else
  brew install gh
fi