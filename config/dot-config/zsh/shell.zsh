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

# Support for mise shims
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Add user private bins to path. 
export PATH=$PATH:$HOME/.bin:$HOME/.local/bin:

# Add go to path
export GOPATH=$HOME/.local/share/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH

# RAMDOM SETTINGS

# Keep various TUIs from changing the terminal title.
export OPENCODE_DISABLE_TERMINAL_TITLE=true
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1

# Work specific settings
if [[ "$ATELIER_TAGS" == *"google3"* ]]; then
  source /etc/bash_completion.d/hgd
  export TERMINFO_DIRS="$HOME/.terminfo:/usr/share/terminfo:/lib/terminfo"
fi
