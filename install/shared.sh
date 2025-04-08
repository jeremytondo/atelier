#!/bin/sh
# Common helper functions

# Function to run a command with sudo if not already root
as_root() {
  # Check if the effective user ID is 0 (root)
  if [ "$(id -u)" -ne 0 ]; then
    # Not root, use sudo
    echo "INFO: Running command with sudo: $*"
    # Execute sudo with the original command and all its arguments
    sudo "$@"
  else
    # Already root, run directly
    echo "INFO: Running command as root: $*"
    # Execute the command directly with all its arguments
    "$@"
  fi
}