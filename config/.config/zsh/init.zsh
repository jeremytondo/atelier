# Init Mise environemnt manager.
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# ZSH auto suggestions.
source ~/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Homebrew on MacOS
if [[ "$(uname -s)" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set up fzf key bindings and fuzzy completion
if command -v fzf &> /dev/null && [[ "$(uname -s)" == "Linux" ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
  source /usr/share/doc/fzf/examples/key-bindings.zsh
else
  source <(fzf --zsh)
fi

# Set default bat color theme
export BAT_THEME="Nord"

# Update PATH for the Google Cloud SDK.
if [ -f $HOME/.local/share/google-cloud-sdk/path.zsh.inc ]; then . $HOME/.local/share/google-cloud-sdk/path.zsh.inc; fi

# Enables shell command completion for gcloud.
if [ -f '$HOME/.local/share/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/.local/share/google-cloud-sdk/completion.zsh.inc'; fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
# Load nvm script if it exists
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# Load nvm bash_completion (optional but recommended)
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Zoxide init must be at the end of this file. 
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
