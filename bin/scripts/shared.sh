# GLOBAL VARIABLES

# Directory the install.sh file is in at the time it is run.
# SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Check to see if an app is already installed.
is_installed() {
  app_name=$1

  if which $app_name &>/dev/null; then
    echo true
  else
    echo false
  fi
}
