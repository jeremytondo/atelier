FROM atelier-base:latest

# --- SSH Setup ---    
RUN update-ca-certificates --fresh \
    # Disable password authentication
    && sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    # Disallow root login via SSH password
    && sed -i 's/^#?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config \
    # UsePAM no can sometimes help with key auth in minimal environments
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
    # Create SSH host keys
    && ssh-keygen -A \
    # Remove the user's password (no password login)
    && passwd -d $USER \
    # Create .ssh directory and set permissions (owner/perms set by entrypoint too, but good to create dir)
    && mkdir -p /home/$USER/.ssh \
    && chown $USER:$USER /home/$USER/.ssh \
    && chmod 700 /home/$USER/.ssh

# --- Add the SSH Entrypoint script ---
COPY /containers/atelier-base/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# --- Add Ghostty Terminfo Definition ---
# Copy the source file generated locally into a temporary location
COPY /containers/atelier-base/xterm-ghostty.terminfo.src /tmp/xterm-ghostty.terminfo.src
# Compile and install the terminfo definition using tic
# -x: Use extended capabilities (matches infocmp -x)
# -o: Specify output directory (standard system location)
RUN tic -x -o /usr/share/terminfo /tmp/xterm-ghostty.terminfo.src \
    # Clean up the temporary source file
    && rm /tmp/xterm-ghostty.terminfo.src

# --- Install additional applications ---
# RUN chmod +x /tmp/install/apps/*.sh && \
#     for script in /tmp/install/apps/*.sh; do \
#         # Skip trying to execute common.sh directly if it's just functions
#         echo "--- Running script: $(basename "$script") ---"; \
#         # Execute using bash, exit build if any script fails
#         # The sourced common.sh will be available within this execution
#         bash "$script" || exit 1; \
#         echo "--- Finished script: $(basename "$script") ---"; \
#     done

# Set the entrypoint script to run
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Expose the SSH port
EXPOSE 22

# Default command for the entrypoint script to execute: Start SSHD
# -D: Don't detach (daemon mode) - keeps the container running
# -e: Log to stderr (useful for docker logs)
CMD ["/usr/sbin/sshd", "-D", "-e"]