# Add the Atelier cli to the local bin.
# Uses a simlink to make updates easy.
source="$HOME/.local/share/atelier/cli/bin/atelier"
symlink="$HOME/.local/bin"

# Make sure the directory exists
mkdir -p "$symlink"

# If the symlink does not exist, create it.
[[ ! -L "$symlink" ]] && ln -s "$source" "$symlink/atelier"
