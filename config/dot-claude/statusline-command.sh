#!/bin/bash

input=$(cat)

dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // ""')
dir=$(basename "$dir")

model=$(printf '%s' "$input" | jq -r '.model.display_name // ""')

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // ""')
branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

parts=""
if [ -n "$dir" ]; then
  parts="\uf07b ${dir}"
fi
if [ -n "$model" ]; then
  [ -n "$parts" ] && parts="${parts} | "
  parts="${parts}\uf51b ${model}"
fi
if [ -n "$branch" ]; then
  [ -n "$parts" ] && parts="${parts} | "
  parts="${parts}\ue65d ${branch}"
fi

printf '%b' "$parts"
