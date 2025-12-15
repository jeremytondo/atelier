# Atelier

Opinionated development environment setup and management.

## Overview

I do a lot of development on remote VMs and I wanted a way to quickly and easily setup a development environment on a new machine. I also wanted to keep a similar setup on my Mac. So, I created Atelier to ensure a consistent, reproducible experience on both MacOS and Arch Linux.

I was inspired by [Omakub](https://github.com/basecamp/omakub) and essentially copied a lot of it to get this up and running. All of the setup and config reflects how I like having my development environment set up.

## Install

Run the following script and then reboot.

```bash
wget -qO- https://raw.githubusercontent.com/jeremytondo/atelier/main/boot.sh | bash
```

## Core Philosophy

This repository serves three main purposes:

### 1. Consistent Cross-Platform Setup
Whether running on a local MacBook or a remote Arch Linux VM, the environment looks and behaves exactly the same. The installation scripts handle the nuances of package management:
*   **Arch Linux**: Uses `yay` for system and AUR packages.
*   **macOS**: Uses Homebrew.

### 2. Dotfiles Management
The `config` directory contains the configuration files for all supported applications (Neovim, Zsh, NVM, etc.). GNU Stow is used to create and manage symlinks, ensuring these files are placed correctly in the home directory while keeping the repository clean.

### 3. Devcontainers
The `devcontainers` directory provides a layered approach to containerized development. The goal is to bring the full "Atelier" terminal experience—zsh, neovim, aliases, and tools—inside the container. This eliminates the context switch between working locally and working inside a devcontainer.

## Included Tools & Features

The setup is comprehensive and includes:

*   **Shell**: Zsh with a custom prompt and autosuggestions.
*   **Editor**: Neovim (configured via LazyVim).
*   **Session Management**: `shpool` is installed and configured to provide persistent sessions, which is critical for maintaining context when disconnecting from remote workstations or VMs.
*   **Runtime**: Node.js (via `nvm`, auto-installing the stable version).
*   **Containerization**: Docker is installed and configured (on Linux).
