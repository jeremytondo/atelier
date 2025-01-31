https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz

if [[ "$OS" == "Linux" ]]; then
  #TODO: Add Linux install.
else
  cd /tmp
  wget -O google-cloud-cli-darwin-arm.tar.gz "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz"
  tar -xf google-cloud-cli-darwin-arm.tar.gz
fi
