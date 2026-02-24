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

# Atelier commands 
alias atc='(cd ~/.local/share/atelier/ && nvim)'
alias ats='~/.local/share/atelier/scripts/status.sh'
alias atp='~/.local/share/atelier/scripts/sync.sh'

# Atelier Go
alias ag='atelier-go'
alias ags='atelier-go sessions list'
alias agk='atelier-go sessions kill'

# Atelier Go Remote Workstation Commands
export ATELIER_CLIENT_ID="${ATELIER_CLIENT_ID:-$(uname -n | cut -d'.' -f1)-$(uuidgen | cut -d'-' -f1)}"

alias agw='autossh -M 0 -q -t workstation -- "/home/jeremytondo/.local/bin/atelier-go --client-id=$ATELIER_CLIENT_ID"'
alias agws='autossh -M 0 -q -t workstation -- /home/jeremytondo/.local/bin/atelier-go sessions list'
alias agwk='autossh -M 0 -q -t workstation -- /home/jeremytondo/.local/bin/atelier-go sessions kill'

alias wst='autossh -M 0 -q -t workstation'

# Work Specific Aliases
if [[ "$ATELIER_TAGS" == *"work"* ]]; then
  alias agc='autossh -M 0 -q -t cloudtop -- "/usr/local/google/home/jeremytondo/.local/bin/atelier-go --client-id=$ATELIER_CLIENT_ID"'
fi

if [[ "$ATELIER_TAGS" == *"google3"* ]]; then
  alias gemini='/google/bin/releases/gemini-cli/tools/gemini'
fi
