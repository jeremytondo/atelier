# Load Atelier local variables
if [[ -f "$HOME/.config/atelier/config.local" ]]; then
  set -a
  source "$HOME/.config/atelier/config.local"
  set +a
fi


# Set default editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Set default bat color theme
export BAT_THEME="Nord"

# Terminal color settings
export COLORTERM="truecolor"

