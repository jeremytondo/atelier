#!/bin/bash

# Usage: rem <project> <action>
# Example: rem blog edit

# --- Configuration ---
HOST="workstation" # Set your SSH host alias here
REMOTE_SCRIPT="~/.local/bin/atelier-remote"
# ---------------------

PROJECT=$1
ACTION=$2

if [ -z "$PROJECT" ] || [ -z "$ACTION" ]; then
  echo "Usage: atelier <project> <action>"
  echo "Actions: edit, shell, opencode"
  exit 1
fi

# We use -t to force TTY allocation, which is required for
# interactive tools like Shpool/Neovim.
ssh -t "$HOST" "$REMOTE_SCRIPT $PROJECT $ACTION"
