# Check to see if an app is already installed.
is_installed() {
  app_name=$1

  if which $app_name &>/dev/null; then
    echo true
  else
    echo false
  fi
}
