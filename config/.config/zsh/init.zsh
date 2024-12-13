if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &> /dev/null; then
  source /usr/share/doc/fzf/examples/completion.zsh
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

export PATH=$PATH:/usr/local/go/bin:$HOME/.local/share/atelier/bin
