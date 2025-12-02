# Start from the base image which already has many tools installed.
FROM jeremytondo/atelier-base:latest

# Set the locale
RUN apt-get update && apt-get install -y locales \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Argument to specify the branch, defaults to "dev"
ARG BRANCH="main"
# Pass it as an environment variable for the user script
ENV BRANCH=${BRANCH}

# Create required directories with correct permissions
RUN mkdir -p /home/devuser/.local/share /home/devuser/tmp && \
    chown -R devuser:devuser /home/devuser/.local /home/devuser/tmp

# Copy the user setup script to the home directory instead of /tmp
COPY setup.sh /home/devuser/tmp/setup.sh
RUN chmod +x /home/devuser/tmp/setup.sh && \
    chown devuser:devuser /home/devuser/tmp/setup.sh

# Switch to devuser to run the script
USER devuser
RUN /home/devuser/tmp/setup.sh

# Switch back to the root user
USER root

# Clean up scripts
RUN rm -rf /home/devuser/tmp/
