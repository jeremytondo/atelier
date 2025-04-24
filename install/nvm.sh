#!/bin/bash
# Script to be run AS devuser to install nvm and latest LTS node
set -e

# NVM Directory (use $HOME which will be /home/devuser when run via runuser)
export NVM_DIR="${HOME}/.nvm"


# Define URL and temporary path for the install script
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
INSTALL_SCRIPT_PATH="/tmp/install-nvm.sh"

echo "Downloading nvm install script from ${INSTALL_SCRIPT_URL}..."
# Download the script securely, follow redirects (-L), fail on error (-f)
curl -fLo "${INSTALL_SCRIPT_PATH}" "${INSTALL_SCRIPT_URL}"
# Make the script executable
chmod +x "${INSTALL_SCRIPT_PATH}"

# Execute the downloaded script (will install nvm to $NVM_DIR)
echo "Executing nvm install script..."
"${INSTALL_SCRIPT_PATH}"

# Clean up the downloaded script
rm "${INSTALL_SCRIPT_PATH}"

# Source nvm script for subsequent commands within THIS script
echo "Sourcing nvm for Node install..."
# Need to use bash's source mechanism directly
source "${NVM_DIR}/nvm.sh"

# Install the latest LTS Node.js version ('node' is alias for latest LTS)
echo "Installing latest LTS Node.js..."
nvm install node

# Set this version as the default for new shells
nvm alias default node

# Clean up nvm cache
nvm cache clear

# Verify installation
echo "NVM install complete. Node/NPM versions:"
# Use nvm which node/npm to show path and run command
nvm which node

echo "nvm setup complete."