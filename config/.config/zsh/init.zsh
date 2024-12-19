# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH=$PATH:/usr/local/go/bin:$HOME/.local/share/atelier/bin

if command -v fzf &> /dev/null; then
  source /usr/share/doc/fzf/examples/completion.zsh
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

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

# Zoxide init must be at the end of this file. 
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
