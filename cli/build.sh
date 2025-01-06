#!/bin/bash

# App name
APP_NAME="atelier"

# Output directory
OUTPUT_DIR="bin"

# Platforms to build for
PLATFORMS=("darwin/amd64" "darwin/arm64" "linux/amd64")

# Clean up previous builds
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Loop through platforms and build
for PLATFORM in "${PLATFORMS[@]}"; do
  IFS="/" read -r GOOS GOARCH <<<"$PLATFORM"

  OUTPUT_PATH="$OUTPUT_DIR/$APP_NAME-$GOOS-$GOARCH"

  echo "Building for $GOOS/$GOARCH..."
  env GOOS=$GOOS GOARCH=$GOARCH go build -o $OUTPUT_PATH
  if [ $? -ne 0 ]; then
    echo "Failed to build for $GOOS/$GOARCH!"
    exit 1
  fi
done

echo "Builds completed! Check the '$OUTPUT_DIR' directory."
