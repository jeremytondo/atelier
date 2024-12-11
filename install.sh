#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Directory the install.sh file is in at the time it is run.
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Includes some shared scripts needed for the install process.
source $SCRIPT_DIR/bin/scripts/shared.sh

# Ensure everything is update before beginning installation.
# sudo apt update -y
# sudo apt upgrade -y

# Installs required apps needed for the rest of the install process.
for app in $SCRIPT_DIR/install/required/*.sh; do source $app; done

# Install Linux terminal apps.
# for app in $SCRIPT_DIR/install/terminal/*.sh; do source $app; done

echo $SCRIPT_DIR

source $SCRIPT_DIR/install/terminal/a-shell.sh
