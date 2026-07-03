# Local ZMX orchestration for remote sessions.

_ash_zmx_bin_for_host() {
  case "$1" in
    mini) printf '%s\n' "/opt/homebrew/bin/zmx" ;;
    *)
      printf 'ash currently supports only: mini\n' >&2
      return 1
      ;;
  esac
}

_ash_validate_session_name() {
  local session_name="$1"

  case "$session_name" in
    ""|*[!A-Za-z0-9._-]*)
      printf 'Session names may contain only letters, numbers, dot, underscore, and dash.\n' >&2
      return 1
      ;;
  esac
}

_ash_attach() {
  local host="$1"
  local session_name="$2"
  local zmx_bin

  zmx_bin="$(_ash_zmx_bin_for_host "$host")" || return 1
  _ash_validate_session_name "$session_name" || return 1

  printf 'Attaching to %s.%s with autossh...\n' "$host" "$session_name"
  autossh -M 0 -q -t "$host" -- "exec $zmx_bin attach $session_name"
}

_ash_fetch_sessions() {
  local host="$1"
  local zmx_bin

  zmx_bin="$(_ash_zmx_bin_for_host "$host")" || return 1
  ssh -q -T "$host" "$zmx_bin list" 2>/dev/null
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
    printf 'Usage: ash mini[.session]\n' >&2
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
