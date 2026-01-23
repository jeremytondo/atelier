# Initial Concept
Atelier is an opinionated development environment setup and management system designed to provide a consistent, reproducible experience across macOS, Linux distributions (Arch, Ubuntu), and remote/containerized environments.

# Product Definition

## Target Users
- **Primary User:** The project creator (personal productivity).
- **Secondary Users:** Developers working on Linux or macOS who seek a standardized, portable development environment.

## Goals
- **Consistency:** Maintain a uniform development environment across different machines (work, personal, cloud) as well as different platforms (macOS, Arch Linux, Ubuntu, and Devcontainers).
- **Reproducibility:** Provide a reliable and quick setup process for new machines.
- **Seamless Integration:** Integrate local tools (Zsh, Neovim, etc.) into devcontainers to eliminate context switching.

## Key Features
- **Automated Installation:** Cross-platform scripts for system-wide setup on macOS and multiple Linux distributions.
- **Dotfiles Management:** Centralized configuration management using GNU Stow for symlinking dotfiles.
- **Layered Devcontainers:** Advanced devcontainer configurations that replicate the full "Atelier" terminal experience inside containers.

## Design Principles
- **Portability:** The setup must be easily deployable on any new machine or VM with minimal manual intervention.
- **Minimal Context Switching:** Ensure that moving between local development and containerized environments feels seamless by preserving tools, aliases, and configurations.
