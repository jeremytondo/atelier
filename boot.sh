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

echo "Cloning Atelier..."
rm -rf ~/.local/share/atelier
git clone https://github.com/jeremytondo/atelier.git ~/.local/share/atelier >/dev/null

echo "Installation starting..."
source ~/.local/share/atelier/install.sh
