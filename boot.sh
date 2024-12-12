#!/bin/bash

set -e

ascii_art='
   _____   __         .__  .__              
  /  _  \_/  |_  ____ |  | |__| ___________ 
 /  /_\  \   __\/ __ \|  | |  |/ __ \_  __ \
/    |    \  | \  ___/|  |_|  \  ___/|  | \/
\____|__  /__|  \___  >____/__|\___  >__|   
        \/          \/             \/       
'

echo -e "$ascii_art"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Atelier..."
rm -rf ~/.local/share/atelier
git clone https://github.com/jeremytondo/atelier.git ~/.local/share/atelier >/dev/null
# if [[ $ATELIER_REF != "master" ]]; then
#   cd ~/.local/share/atelier
#   git fetch origin "${OMAKUB_REF:-stable}" && git checkout "${OMAKUB_REF:-stable}"
#   cd -
# fi

echo "Installation starting..."
source ~/.local/share/atelier/install.sh
