# Local ZMX orchestration for remote sessions.

_ash_zmx_remote_resolver() {
  printf '%s\n' 'zmx_bin=$(command -v zmx 2>/dev/null || true)
if [ -z "$zmx_bin" ]; then
  for zmx_candidate in "$HOME/.local/bin/zmx" /opt/homebrew/bin/zmx /usr/local/bin/zmx /usr/bin/zmx; do
    if [ -x "$zmx_candidate" ]; then
      zmx_bin="$zmx_candidate"
      break
    fi
  done
fi
if [ -z "$zmx_bin" ]; then
  printf "%s\n" "zmx was not found on the remote host. Install zmx or put it on PATH." >&2
  exit 127
fi'
}

_ash_zmx_remote_command() {
  local zmx_args="$1"

  printf '%s\nexec "$zmx_bin" %s\n' "$(_ash_zmx_remote_resolver)" "$zmx_args"
}

_ash_validate_session_name() {
  local session_name="$1"

  case "$session_name" in
    ""|*[!A-Za-z0-9._:-]*)
      printf 'Session names may contain only letters, numbers, dot, underscore, dash, and colon.\n' >&2
      return 1
      ;;
  esac
}

_ash_attach() {
  local host="$1"
  local session_name="$2"

  _ash_validate_session_name "$session_name" || return 1

  printf 'Attaching to %s.%s with autossh...\n' "$host" "$session_name"
  autossh -M 0 -q -t "$host" -- "$(_ash_zmx_remote_command "attach $session_name")"
}

_ash_fetch_sessions() {
  local host="$1"

  ssh -q -T "$host" "$(_ash_zmx_remote_command list)"
}

_ash_format_sessions() {
  while IFS=$'\t' read -r name pid clients created dir; do
    name="${name#*name=}"
    pid="${pid#*pid=}"
    clients="${clients#*clients=}"
    dir="${dir#*start_dir=}"

    [[ -n "$name" ]] || continue
    printf "%-20s pid:%-8s clients:%-2s %s\n" "$name" "$pid" "$clients" "$dir"
  done
}

_ash_pick_session() {
  local host="$1"
  local sessions display output rc query key selected session_name

  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf is required for interactive session picking.\n' >&2
    return 1
  fi

  if ! sessions="$(_ash_fetch_sessions "$host")"; then
    printf 'Could not fetch zmx sessions from %s.\n' "$host" >&2
    return 1
  fi

  display="$(printf '%s\n' "$sessions" | _ash_format_sessions)"
  output=$({ [[ -n "$display" ]] && printf '%s\n' "$display"; } | fzf \
    --print-query \
    --expect=ctrl-a \
    --height=40% \
    --reverse \
    --prompt="zmx on $host> " \
    --header="Enter: select | Ctrl-A: create new")

  rc=$?
  query="$(printf '%s\n' "$output" | sed -n '1p')"
  key="$(printf '%s\n' "$output" | sed -n '2p')"
  selected="$(printf '%s\n' "$output" | sed -n '3p')"

  if [[ "$key" == "ctrl-a" && -n "$query" ]]; then
    session_name="$query"
  elif [[ $rc -eq 0 && -n "$selected" ]]; then
    session_name="${selected%% *}"
  elif [[ -n "$query" ]]; then
    session_name="$query"
  else
    return 130
  fi

  _ash_attach "$host" "$session_name"
}

ash() {
  local target="$1"
  local host session_name

  if [[ -z "$target" ]]; then
    printf 'Usage: ash host[.session]\n' >&2
    return 1
  fi

  if [[ "$target" == *.* ]]; then
    host="${target%%.*}"
    session_name="${target#*.}"
    _ash_attach "$host" "$session_name"
  else
    _ash_pick_session "$target"
  fi
}
