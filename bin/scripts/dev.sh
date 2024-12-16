# Create/attach to a tmux session set up for editing the Atelier app.

dev() {
  session_name="atelier"

  # Attempt to attach to the session, ignoring errors
  tmux attach-session -t $session_name 2>/dev/null

  # If the attachment fails, create a new session
  if [ $? -ne 0 ]; then
    # Create the session and open Neovim in the first window
    tmux new-session -s $session_name -d -c ~/.local/share/atelier/ 'nvim .'

    # Create a new window
    tmux new-window -t $session_name:2

    # Switch back the first window
    tmux select-window -t $session_name:1

    # Attach to the session.
    tmux attach-session -t $session_name
  fi
}
