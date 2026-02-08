# ZSH auto suggestions.
# source ~/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Homebrew on MacOS
if [[ "$(uname -s)" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Temporarily set as this will work in all cases I think once I standardize
# the install methods across platforms.
source <(fzf --zsh)
bindkey '^[[Z' autosuggest-accept  # shift + tab  | autosuggest

# Set default bat color theme
# TODO: Switch up this theme to Catppuccion.
export BAT_THEME="Nord"

# Update PATH for the Google Cloud SDK.
if [ -f $HOME/.local/share/google-cloud-sdk/path.zsh.inc ]; then . $HOME/.local/share/google-cloud-sdk/path.zsh.inc; fi

# Enables shell command completion for gcloud.
if [ -f '$HOME/.local/share/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/.local/share/google-cloud-sdk/completion.zsh.inc'; fi

# Mise Setup
eval "$(~/.local/bin/mise activate zsh)"

# NVM (Node Version Manager)
# export NVM_DIR="$HOME/.nvm"
# # Load nvm script if it exists
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# # Load nvm bash_completion (optional but recommended)
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Set default editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Zoxide init must be at the end of this file. 
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
