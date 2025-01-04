# History settings
HISTFILE=~/.histfile
HISTSIZE=32768
SAVEHIST=32768

# PATH
#
# Add user private bins to path. 
export PATH=$PATH:$HOME/.bin:$HOME/.local/bin:

# Add go to path
export GOPATH=$HOME/.local/share/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH
