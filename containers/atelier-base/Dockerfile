# Use the latest Ubuntu LTS version (currently 24.04)
FROM ubuntu:24.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Username for the non-root user
ARG USERNAME="devuser"
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# --- Set environment variables for the container ---
ENV USERNAME=$USERNAME

# --- Copy the install scripts into the image ---
COPY /install/ /tmp/install/

# --- Set up non root user ---
# Check if a user with UID 1000 exists and delete if it does
RUN id -u 1000 && userdel -r $(getent passwd 1000 | cut -d: -f1) || true && \
    # Check if a group with GID 1000 exists and delete if it does
    id -g 1000 && groupdel $(getent group 1000 | cut -d: -f1) || true && \
    # Creat the user
    groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID --create-home $USERNAME && \
    # Add user to sudo group
    usermod -aG sudo $USERNAME && \
    # Set home directory permissions
    chown -R $USERNAME:$USERNAME /home/$USERNAME && \
    chmod -R 755 /home/$USERNAME && \
    # Create workspace and other directories
    mkdir -p /workspaces && \
    chown -R $USERNAME:$USERNAME /workspaces  && \
    chmod 755 /workspaces && \
    mkdir -p /home/$USERNAME/.local && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.local && \
    chmod 755 /home/$USERNAME/.local && \
    mkdir -p /home/$USERNAME/.local/share && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.local/share && \
    chmod 755 /home/$USERNAME/.local/share

# --- Install base packages --- 
RUN chmod +x /tmp/install/base-install.sh && \ 
    ./tmp/install/base-install.sh

# --- Set default shell to zsh ---
RUN usermod -s /usr/bin/zsh $USERNAME

# --- Configure Locale --- 
# Generate the en_US.UTF-8 locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Set locale environment variables system-wide
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# --- Copy Atelier into user's home directory and install dotfiles ---
COPY . /home/$USERNAME/.local/share/atelier/
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/.local/share/atelier/ && \
    cd /home/$USERNAME/.local/share/atelier/config && \
    # Install dotfiles. gosu performs this asction as the non-root user.
    gosu $USERNAME stow -t /home/$USERNAME .

# -- Clean up the apt cache and temporary files --
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -f /home/$USERNAME/.bashrc /home/$USERNAME/.bash_logout /home/$USERNAME/.profile