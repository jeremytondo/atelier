#!/usr/bin/env bash
set -euo pipefail

REPO_PATH="$HOME/.local/share/atelier"

# Navigate to the repo
cd "$REPO_PATH"

echo "Syncing latest changes for atelier..."
git pull

echo "Successfully synced atelier."
