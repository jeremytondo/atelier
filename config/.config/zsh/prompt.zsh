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
PS1=$'\uf0a9 '
RPROMPT=\$vcs_info_msg_0_
# PS1="\[\e]0;\w\a\]$PS1"
