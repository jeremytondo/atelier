# Dockerfile for Atelier Base Devcontainer
FROM mcr.microsoft.com/devcontainers/base:ubuntu24.04

# Install common development tools
# hadolint ignore=DL3008
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && apt-get -y install --no-install-recommends \
    git \
    zsh \
    stow \
    zoxide \
    ripgrep \
    bat \
    fd-find \
    wget \
    neovim \
    tldr \
    gh \
    eza \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

USER vscode
WORKDIR /home/vscode

ARG GIT_BRANCH=main
ENV GIT_BRANCH=${GIT_BRANCH}

# Copy the setup script and run it
COPY --chown=vscode:vscode setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh && /tmp/setup.sh

# Set Zsh as the default shell
CMD [ "zsh" ]
