#!/bin/bash

# Creates a simlink to the Atelier executable in the .local/bin directory.
# This makes it easy to run the app from the command like.

INSTALL_DIR="~/.local/bin"

mkdir -p $INSTALL_DIR
ln -s ~/projects/atelier/bin/atelier $INSTALL_DIR/atelier
