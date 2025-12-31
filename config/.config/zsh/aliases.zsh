# File system
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd='z'

if [[ $(uname -s) == "Linux" ]]; then
  alias fd='fdfind'
fi

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias n='nvim'
alias g='git'
alias d='docker'
alias r='rails'
alias lzg='lazygit'
alias lzd='lazydocker'
alias dc='devcontainer'

# Atelier Go
alias ag='atelier-go'
alias ags='atelier-go sessions list'
alias agk='atelier-go sessions kill'

# Atelier Go Remote Workstation Commands
alias agw='autossh -M 0 -q -t ag -- /home/jeremytondo/.local/bin/atelier-go'
alias agws='autossh -M 0 -q -t ag -- /home/jeremytondo/.local/bin/atelier-go sessions list'
alias agwk='autossh -M 0 -q -t ag -- /home/jeremytondo/.local/bin/atelier-go sessions kill'

if [[ "$(uname -s)" == "Linux" ]]; then
  alias bat='batcat'
fi

# Git
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Edit Atelier Config
alias atc='nvim ~/.local/share/atelier/config/.config/'
