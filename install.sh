#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Includes some shared scripts needed for the install process.
source bin/scripts/shared.sh

# Ensure everything is update before beginning installation.
# sudo apt update -y
# sudo apt upgrade -y

# Installs required apps needed for the rest of the install process.
for app in $SCRIPT_DIR/install/required/*.sh; do source $app; done

# Install Linux terminal apps.
