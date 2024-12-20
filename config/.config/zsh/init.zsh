
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

# Zoxide init must be at the end of this file. 
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
