PROJECTS_FOLDER=$HOME/projects

project() {
  project_name=$1
  project_folder=$PROJECTS_FOLDER/$project_name

  # Check for running tmux sessions
  sessions=$(tmux list-sessions 2>/dev/null)

  # If no project was passed and there are tmux sessions running
  # open the latest tmux session.
  if [[ -n "$sessions" ]] && [[ -z "$project_name" ]]; then
    tmux a
    return 0
  fi

  # If no project was passed and there are no open tmux sessions.
  if ! [[ -n "$sessions" ]] && [[ -z "$project_name" ]]; then
    echo "No open projects."
    return 0
  fi

  # The project name 'atelier' opens a special project used to manage
  # the Atelier code base.
  if [[ "$project_name" == "atelier" ]]; then
    open_project atelier
    return 0
  fi

  # If the project folder exists, open it otherwise offer to create it.
  if [ -d "$project_folder" ]; then
    open_project $project_name
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

  gum confirm "Would you like to create from git repository?" &&
    create_git_project $project_name || create_empty_project $project_name
}

create_git_project() {
  project_name=$1
  git_repository=$2

  repo_url=$(gum input --placeholder "Enter Git Repo URL:")

  git clone $repo_url $PROJECTS_FOLDER/$project_name
}

create_empty_project() {
  project_name=$1
  mkdir $PROJECTS_FOLDER/$project_name
}
