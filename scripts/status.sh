#!/usr/bin/env bash
set -euo pipefail

REPO_PATH="$HOME/.local/share/atelier"

# Navigate to the repo
cd "$REPO_PATH"

# Fetch latest changes from GitHub silently
git fetch origin >/dev/null 2>&1

# Get the current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "--- Atelier Config Status ---"
echo "Branch:  $BRANCH"

# Check for uncommitted local changes
if [[ -n $(git status --porcelain) ]]; then
  echo -e "\n[Local Changes]:"
  git status --short
else
  echo -e "\nLocal repo is clean."
fi

# Check for remote differences
UPSTREAM_DIFF=$(git rev-list --left-right --count "$BRANCH...origin/$BRANCH")
LEFT=$(echo "$UPSTREAM_DIFF" | awk '{print $1}')
RIGHT=$(echo "$UPSTREAM_DIFF" | awk '{print $2}')

if [ "$LEFT" -gt 0 ]; then
  echo -e "You have $LEFT unpushed commit(s)."
fi

if [ "$RIGHT" -gt 0 ]; then
  echo -e "GitHub has $RIGHT new commit(s). Run 'git pull' to update."
  echo "Incoming changes:"
  git diff --name-only "$BRANCH...origin/$BRANCH" | sed 's/^/  - /'
else
  echo "You are up to date with origin/$BRANCH."
fi
