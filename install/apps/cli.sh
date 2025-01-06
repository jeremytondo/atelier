# Add the Atelier cli to the local bin.
# Uses a simlink to make updates easy.

# Supported platforms
SUPPORTED_PLATFORMS=("darwin/amd64" "darwin/arm64" "linux/amd64")

# Get OS and architecture
OSNAME=$(uname -s | tr '[:upper:]' '[:lower:]') # Converts to lowercase
ARCH=$(uname -m)

# Normalize architecture
case $ARCH in
x86_64)
  ARCH="amd64"
  ;;
arm64 | aarch64)
  ARCH="arm64"
  ;;
esac

# Current platform
CURRENT_PLATFORM="$OSNAME/$ARCH"

# Check if the current platform is supported
if [[ " ${SUPPORTED_PLATFORMS[*]} " =~ " $CURRENT_PLATFORM " ]]; then
  source="$HOME/.local/share/atelier/cli/bin/atelier-$OSNAME-$ARCH"
  symlink="$HOME/.local/bin"

  # Make sure the directory exists
  mkdir -p "$symlink"

  # If the symlink does not exist, create it.
  [[ ! -L "$symlink" ]] && ln -s "$source" "$symlink/atelier"
  # exit 0
else
  echo "Current platform ($CURRENT_PLATFORM) is not supported."
  # exit 1
fi
