PROJECTS_FOLDER=$HOME/projects

dev() {
  project_name=$1
  project_folder=$PROJECTS_FOLDER/$project_name

  # Check for running tmux sessions
  sessions=$(tmux list-sessions 2>/dev/null)

  if [[ -n "$sessions" ]]; then
    tmux a
    return 0
  else
    echo "There are no open projects."
    return 0
  fi

  if [[ "$project_name" == "atelier" ]]; then
    open_project atelier
    return 0
  fi

  if [ -d "$project_folder" ]; then
    echo "The folder  exists."
  else
    gum confirm "The project does not exist. Would you like to create it?" && create_project $project_name
  fi
}

open_project() {
  project_name=$1

  # Attempt to attach to the session, ignoring errors
  tmux attach-session -t $project_name 2>/dev/null

  # If the attachment fails, create a new session
  if [ $? -ne 0 ]; then
    # Create the session and open Neovim in the first window
    tmux new-session -s $project_name -d -c ~/.local/share/atelier/ 'nvim .'

    # Create a new window
    tmux new-window -t $project_name:2

    # Switch back the first window
    tmux select-window -t $project_name:1

    # Attach to the session.
    tmux attach-session -t $project_name
  fi
}

create_project() {
  project_name=$1
  mkdir -p $PROJECTS_FOLDER/$project_name
}
