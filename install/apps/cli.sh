# Add the Atelier cli to the local bin.
# Uses a symlink to make updates easy.
source="$HOME/.local/share/atelier/cli/bin/atelier"
symlink="$HOME/.local/bin"

# If the symlink does not exist, create it.
[[ ! -L "$symlink" ]] && ln -s "$source" "$symlink"
