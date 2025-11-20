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