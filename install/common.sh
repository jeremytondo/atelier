#!/bin/bash
# Atelier Common Library - Shared functions for install scripts

# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Printing functions
print_step() {
  echo -e "${GREEN}==>${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

print_info() {
  echo -e "${BLUE}Info:${NC} $1"
}

# Read packages from file and return as space-separated list
read_packages() {
  local file="$1"
  if [ ! -f "$file" ]; then
    print_error "Package file not found: $file"
    return 1
  fi
  # Read file, remove comments and empty lines, join with spaces
  grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' '
}

# Install packages from a given file using brew
install_packages() {
  local category="$1"
  local file="$2"
  print_step "Installing $category..."

  local packages=$(read_packages "$file")
  [ -n "$packages" ] && brew install $packages
}

# Check if command exists
check_command() {
  command -v "$1" >/dev/null 2>&1
}

# Get script directory (standardized)
get_script_dir() {
  echo "$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
}

# Parse a package line and return package name for specific platform
# Returns empty string if package should not be installed on this platform
parse_package_for_platform() {
  local line="$1"
  local target_platform="$2"

  # Split line into tokens
  local tokens=($line)
  local base_package=""
  local found_target_override=""
  local found_any_platform=false

  # Process each token
  for token in "${tokens[@]}"; do
    if [[ "$token" == *":"* ]]; then
      # This is a platform:package pair
      local platform=$(echo "$token" | cut -d: -f1)
      local package=$(echo "$token" | cut -d: -f2)
      found_any_platform=true

      if [ "$platform" == "$target_platform" ]; then
        found_target_override="$package"
      fi
    else
      # This is a base package name
      base_package="$token"
    fi
  done

  # Apply the logic rules
  if [ -n "$found_target_override" ]; then
    # Rule 2 & 3: Platform override found
    echo "$found_target_override"
  elif [ -n "$base_package" ]; then
    # Rule 1 & 3: Base package exists, install if no platform restrictions
    echo "$base_package"
  elif [ "$found_any_platform" = true ]; then
    # Rule 4: Only platform-specific, target not found
    echo ""
  else
    # Empty line or invalid
    echo ""
  fi
}

# Enhanced read_packages function for platform-specific parsing
read_packages_for_platform() {
  local file="$1"
  local platform="$2"
  local packages=""

  if [ ! -f "$file" ]; then
    print_error "Package file not found: $file"
    return 1
  fi

  # Process each non-comment, non-empty line
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    # Parse package for this platform
    local pkg=$(parse_package_for_platform "$line" "$platform")

    # Add to package list if not empty
    if [ -n "$pkg" ]; then
      packages="$packages $pkg"
    fi
  done <"$file"

  echo "$packages"
}
