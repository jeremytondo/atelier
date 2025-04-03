# Use the latest Ubuntu LTS version (currently 24.04)
FROM ubuntu:24.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# URL of the dotfiles git repository (MUST be provided via --build-arg)
ARG DOTFILES_REPO_URL
# Name of the directory to clone the dotfiles into (MUST be provided via --build-arg)
ARG DOTFILES_CLONE_NAME="atelier" # Default name if not provided
ARG NVM_VERSION=v0.39.7

# Install base tools, SSH Server, sudo, and update CA certs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        stow \
        fzf \ 
        ripgrep \
        bat \
        eza \
        zoxide \
        plocate \
        btop \
        apache2-utils \
        fd-find \
        tldr \
        unzip \
        openssh-server \
        sudo \
        ca-certificates \
        ncurses-bin \
        passwd \
        zsh \
        locales \
    && update-ca-certificates --fresh \
    && rm -rf /var/lib/apt/lists/* \
    # --- Configure SSHD Securely ---
    # Disable password authentication
    && sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    # Disallow root login via SSH password
    && sed -i 's/^#?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config \
    # UsePAM no can sometimes help with key auth in minimal environments
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
    # Create SSH host keys
    && ssh-keygen -A \
    # --- Create non-root user 'devuser' ---
    && useradd --create-home --shell /bin/bash devuser \
    && passwd -d devuser \
    # Set the default shell to zsh
    && chsh -s /usr/bin/zsh devuser \
    # Add user to sudo group (optional, but common for dev environments)
    && usermod -aG sudo devuser \
    # Create .ssh directory and set permissions (owner/perms set by entrypoint too, but good to create dir)
    && mkdir -p /home/devuser/.ssh \
    && chown devuser:devuser /home/devuser/.ssh \
    && chmod 700 /home/devuser/.ssh \
    # Clean up default bash config files
    && rm -f /home/devuser/.bashrc /home/devuser/.bash_logout /home/devuser/.profile

# === Configure Locale ===
# Generate the en_US.UTF-8 locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
# Set locale environment variables system-wide
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# --- Install zsh-autosuggestions via git clone ---
RUN echo "Cloning zsh-autosuggestions..." \
    && export ZSH_AUTOSUGGEST_DIR="/home/devuser/.local/share/zsh-autosuggestions" \
    && mkdir -p "$(dirname "${ZSH_AUTOSUGGEST_DIR}")" && chown devuser:devuser /home/devuser/.local /home/devuser/.local/share \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_AUTOSUGGEST_DIR}" \
    && chown -R devuser:devuser "${ZSH_AUTOSUGGEST_DIR}"

# --- Add Ghostty Terminfo Definition ---
# Copy the source file generated locally into a temporary location
COPY xterm-ghostty.terminfo.src /tmp/xterm-ghostty.terminfo.src
# Compile and install the terminfo definition using tic
# -x: Use extended capabilities (matches infocmp -x)
# -o: Specify output directory (standard system location)
RUN tic -x -o /usr/share/terminfo /tmp/xterm-ghostty.terminfo.src \
    # Clean up the temporary source file
    && rm /tmp/xterm-ghostty.terminfo.src
# --- End Terminfo Definition ---

# --- Clone Dotfiles and Run Stow ---
# This runs as root, but targets the devuser's home directory
RUN if [ -z "${DOTFILES_REPO_URL}" ]; then echo "ERROR: Build-arg DOTFILES_REPO_URL is required." >&2; exit 1; fi && \
    echo "Cloning dotfiles from ${DOTFILES_REPO_URL} into /home/devuser/.local/share/${DOTFILES_CLONE_NAME}" && \
    # Define paths
    export CLONE_DIR="/home/devuser/.local/share/${DOTFILES_CLONE_NAME}" && \
    export TARGET_DIR="/home/devuser" && \
    export STOW_SRC_DIR="${CLONE_DIR}/config" && \
    # Create parent directory for clone and set owner
    mkdir -p "$(dirname "${CLONE_DIR}")" && chown devuser:devuser /home/devuser/.local /home/devuser/.local/share && \
    # Clone the repository (shallow clone)
    git clone --depth 1 "${DOTFILES_REPO_URL}" "${CLONE_DIR}" && \
    # Check if the stow source directory exists before running stow
    if [ -d "${STOW_SRC_DIR}" ]; then \
      echo "Running stow from ${STOW_SRC_DIR} to ${TARGET_DIR}" && \
      stow --verbose=1 --dir="${STOW_SRC_DIR}" --target="${TARGET_DIR}" --stow . ; \
    else \
      echo "WARNING: Stow source directory ${STOW_SRC_DIR} not found. Skipping stow." ; \
    fi && \
    # Ensure the cloned repo files are owned by the user
    chown -R devuser:devuser "${CLONE_DIR}"

# --- Install Latest Stable Neovim AppImage (Extract Method - Hardcoded for amd64/x86_64) ---
RUN echo "INFO: Installing latest stable Neovim AppImage for amd64/x86_64 architecture." && \
    # Hardcode architecture string expected by Neovim release assets
    export NVIM_ARCH="x86_64" && \
    # Construct the download URL using the hardcoded architecture
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.appimage" && \
    echo "Downloading latest stable Neovim AppImage (${NVIM_ARCH}) from $NVIM_URL" && \
    # Download AppImage to /tmp
    curl -fLo /tmp/nvim.appimage "$NVIM_URL" && \
    # Make it executable (needed for extraction)
    chmod +x /tmp/nvim.appimage && \
    # Extract the AppImage contents
    # NOTE: Extraction creates a 'squashfs-root' directory in the current dir (/tmp)
    cd /tmp && ./nvim.appimage --appimage-extract && \
    # Move the extracted application structure to a permanent location, like /opt
    mv /tmp/squashfs-root /opt/neovim && \
    # Create a symbolic link in /usr/local/bin for easy access
    ln -s /opt/neovim/AppRun /usr/local/bin/nvim && \
    # Clean up the downloaded AppImage file
    rm /tmp/nvim.appimage
# --- End Neovim Install ---

# Since the Ubuntu 24.04 fzf package doesn't place them here,
# download them manually to satisfy the dotfiles' source commands.
RUN export FZF_DOC_DIR="/usr/share/doc/fzf/examples" && \
    echo "Manually downloading fzf zsh scripts to ${FZF_DOC_DIR}..." && \
    mkdir -p "${FZF_DOC_DIR}" && \
    curl -fLo "${FZF_DOC_DIR}/completion.zsh" \
      https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh && \
    curl -fLo "${FZF_DOC_DIR}/key-bindings.zsh" \
      https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh && \
    # Ensure they are world-readable
    chmod 644 "${FZF_DOC_DIR}/completion.zsh" "${FZF_DOC_DIR}/key-bindings.zsh"

# === Install NVM and Node.js via Script ===
# Copy the script into the image
COPY install-nvm-node.sh /usr/local/bin/install-nvm-node.sh
# Make it executable and run it as devuser, then remove script
RUN chmod +x /usr/local/bin/install-nvm-node.sh && \
    # Ensure home dir is writeable by user before running script
    chown devuser:devuser /home/devuser && \
    # Run the script as devuser
    runuser -u devuser /usr/local/bin/install-nvm-node.sh && \
    # Clean up the script
    rm /usr/local/bin/install-nvm-node.sh

# --- Add the SSH Entrypoint script ---
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint script to run
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# --- End Entrypoint Setup ---

# Expose the SSH port
EXPOSE 22

# Default command for the entrypoint script to execute: Start SSHD
# -D: Don't detach (daemon mode) - keeps the container running
# -e: Log to stderr (useful for docker logs)
CMD ["/usr/sbin/sshd", "-D", "-e"]