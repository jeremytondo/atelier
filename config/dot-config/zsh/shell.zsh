# History settings
HISTFILE=~/.histfile
HISTSIZE=32768
SAVEHIST=32768

# Load Atelier local variables
if [[ -f "$HOME/.config/atelier/config.local" ]]; then
  set -a
  source "$HOME/.config/atelier/config.local"
  set +a
fi

# PATH
#
# Add user private bins to path. 
export PATH=$PATH:$HOME/.bin:$HOME/.local/bin:

# Add go to path
export GOPATH=$HOME/.local/share/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH

# RAMDOM SETTINGS

# Keep OpenCode from changing the terminal title.
export OPENCODE_DISABLE_TERMINAL_TITLE=true

# Work specific settings
if [[ "$ATELIER_TAGS" == *"work"* ]]; then
  source /etc/bash_completion.d/hgd
  export TERMINFO_DIRS="$HOME/.terminfo:/usr/share/terminfo:/lib/terminfo"
fi
