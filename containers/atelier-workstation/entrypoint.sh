#!/bin/sh
# Entrypoint script to configure SSH key from environment variable and start sshd
set -e

if [ -z "${USERNAME}" ]; then
    echo "ERROR: USERNAME environment variable is not set"
    exit 1
fi

USER_HOME="/home/${USERNAME}"
SSH_DIR="${USER_HOME}/.ssh"
AUTH_KEYS_FILE="${SSH_DIR}/authorized_keys"

# Add debug output
echo "DEBUG: Current user: $(id)"
echo "DEBUG: USERNAME: ${USERNAME}"
echo "DEBUG: USER_HOME: ${USER_HOME}"
echo "${SSH_PUBLIC_KEY}"

# Ensure .ssh directory exists with correct permissions
mkdir -p "${SSH_DIR}"
chown $USERNAME:$USERNAME "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# Check if SSH_PUBLIC_KEY environment variable is set
if [ -n "${SSH_PUBLIC_KEY}" ]; then
  echo "INFO: Adding public key from SSH_PUBLIC_KEY environment variable to ${AUTH_KEYS_FILE}"
  printf '%s\n' "${SSH_PUBLIC_KEY}" > "${AUTH_KEYS_FILE}"
  chown $USERNAME:$USERNAME "${AUTH_KEYS_FILE}"
  chmod 600 "${AUTH_KEYS_FILE}"
  echo "INFO: Public key added."
else
  echo "WARNING: SSH_PUBLIC_KEY environment variable not set. SSH key access will not work unless keys are mounted."
  touch "${AUTH_KEYS_FILE}"
  chown $USERNAME:$USERNAME "${AUTH_KEYS_FILE}"
  chmod 600 "${AUTH_KEYS_FILE}"
fi

# --- FIX: Ensure the sshd privilege separation directory exists ---
echo "INFO: Ensuring sshd privilege separation directory /run/sshd exists..."
mkdir -p /run/sshd
chmod 755 /run/sshd
# --- END FIX ---

# Execute the command provided as arguments (e.g., the CMD from Dockerfile)
echo "INFO: Executing command: $@"
exec "$@"