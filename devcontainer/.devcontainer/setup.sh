#!/bin/bash
set -e

echo "Starting Atelier devcontainer setup..."

# 1. Clean up default configs to prevent Stow conflicts
echo "Removing default configuration files..."
rm -f $HOME/.zshrc $HOME/.bashrc $HOME/.profile
rm -rf $HOME/.oh-my-zsh

# 2. Install zsh-autosuggestions
echo "Installing zsh-autosuggestions..."
if [ ! -d "/usr/local/share/zsh-autosuggestions" ]; then
  sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/local/share/zsh-autosuggestions
fi

# 3. Prepare local share directory
echo "Setting up local share directory..."
mkdir -p $HOME/.local/share

# Clone fzf, run install --bin, and create symlink
echo "Installing fzf from source using --bin flag..."
if [ ! -d "$HOME/.local/share/fzf" ]; then
    git clone https://github.com/junegunn/fzf.git "$HOME/.local/share/fzf"
else
    echo "fzf repository already exists, updating..."
    cd "$HOME/.local/share/fzf"
    git pull
fi
"$HOME/.local/share/fzf/install" --bin
sudo mkdir -p /usr/local/bin # Ensure target directory exists
sudo ln -sf "$HOME/.local/share/fzf/bin/fzf" /usr/local/bin/fzf

# 4. Clone Atelier repository
echo "Cloning Atelier repository from branch ${GIT_BRANCH}..."
cd $HOME
if [ ! -d ".local/share/atelier" ]; then
  git clone --branch ${GIT_BRANCH} https://github.com/jeremytondo/atelier.git .local/share/atelier
else
  echo "Atelier repository already exists, updating..."
  cd .local/share/atelier
  git fetch
  git checkout ${GIT_BRANCH}
  git pull origin ${GIT_BRANCH}
fi

# 5. Stow dotfiles
echo "Setting up dotfiles with stow..."
cd $HOME/.local/share/atelier
stow -t $HOME config

echo "Atelier setup complete!"

