# Load Atelier local variables
if [[ -f "$HOME/.config/atelier/config.local" ]]; then
  set -a
  source "$HOME/.config/atelier/config.local"
  set +a
fi

# ZSH auto suggestions.
# source ~/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Homebrew on MacOS
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# FZF
source <(fzf --zsh)
bindkey '^[[Z' autosuggest-accept  # shift + tab  | autosuggest

# Update PATH for the Google Cloud SDK.
if [ -f $HOME/.local/share/google-cloud-sdk/path.zsh.inc ]; then . $HOME/.local/share/google-cloud-sdk/path.zsh.inc; fi
# Enables shell command completion for gcloud.
if [ -f '$HOME/.local/share/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/.local/share/google-cloud-sdk/completion.zsh.inc'; fi

# Mise Setup
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Zoxide init must be at the end of this file. 
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# OpenCode 
export OPENCODE_DISABLE_TERMINAL_TITLE=true

# Claude Code
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1

# Work Specific Tools
if [[ "$ATELIER_TAGS" == *"work"* ]]; then
  source /etc/bash_completion.d/jjd
fi

# Google3 Specific tools
if [[ "$ATELIER_TAGS" == *"google3"* ]]; then
  source /etc/bash_completion.d/hgd
  export TERMINFO_DIRS="$HOME/.terminfo:/usr/share/terminfo:/lib/terminfo"
fi

