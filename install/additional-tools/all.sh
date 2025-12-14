#!/bin/bash
set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

print_step "Running all additional tool installers..."

# Iterate over all .sh files in the current directory
for script in "$SCRIPT_DIR"/*.sh; do
  script_name=$(basename "$script")
  
  # Skip this script (all.sh)
  if [ "$script_name" == "all.sh" ]; then
    continue
  fi
  
  # Run the script
  print_info "Executing $script_name..."
  bash "$script"
done

print_step "All additional tools installed successfully."
