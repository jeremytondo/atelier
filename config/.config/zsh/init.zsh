# if command -v fzf &> /dev/null; then
#   source /usr/share/doc/fzf/examples/completion.zsh
#   source /usr/share/doc/fzf/examples/key-bindings.zsh
# fi

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
source <(fzf --zsh)
# eval "$(fzf --zsh)"

# Zoxide init must be at the end of this file. 
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
