#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/atelier/config.local"

echo "--- Atelier Local Config ---"

if [[ -f "$CONFIG_FILE" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && (continue)
        
        # Only process lines with an equals sign
        if [[ "$line" == *"="* ]]; then
            key="${line%%=*}"
            value="${line#*=}"
            # Strip leading/trailing quotes using sed to avoid escaping issues in this environment
            value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
            
            printf "% -15s: %s\n" "$key" "$value"
        fi
    done < "$CONFIG_FILE"
else
    echo "No local configuration found at $CONFIG_FILE"
fi