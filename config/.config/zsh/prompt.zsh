# Technicolor dreams
force_color_prompt=yes
color_prompt=yes

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' %b'

# Simple prompt with path in the window/pane title and caret for typing line
setopt PROMPT_SUBST

if [[ "$(uname -s)" == "Darwin" ]]; then
  PS1=$'\uf0a9 '
  RPROMPT="\$vcs_info_msg_0_"
elif [[ -f "/.dockerenv" || -n "$container" ]]; then
  # PS1=$'%{\e[33m%}\uf0a9 %{\e[0m%}'
  PS1=$'%{\e[38;5;92m%}\uf0a9 %{\e[0m%}'
else
  PS1=$'%{\e[34m%}\uf0a9 %{\e[0m%}'
  RPROMPT="\$vcs_info_msg_0_"
  
  # This right prompt version includes the shpool session name
  # RPROMPT=$'\$vcs_info_msg_0_${(0)${SHPOOL_SESSION_NAME:+ \uf50c \$SHPOOL_SESSION_NAME}}'
fi
