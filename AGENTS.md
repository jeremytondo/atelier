# Atelier Development Environment - Agent Guidelines

## System Overview

Atelier is a comprehensive development environment management system designed to provide a consistent, reproducible, and efficient development experience across various platforms and scenarios. It offers a suite of features including:

- **Dotfiles Management**: Automated configuration synchronization using GNU Stow for consistent settings across environments.
- **Cross-Platform Setup**: Streamlined tool installation and configuration across macOS (Homebrew), Arch Linux, and Ubuntu (apt) for consistent dev container environments.
- **Containerized Environments**: Support for reproducible development containers with devcontainers, facilitating isolated and consistent project setups.

## Core Components

### Key Features

**Smart Navigation**: Zoxide integration for frecency-based project suggestions

## Installation & Setup

### Bootstrap Installation
```bash
wget -qO- https://raw.githubusercontent.com/jeremytondo/atelier/main/boot.sh | bash
```

### Manual Installation
```bash
bash boot.sh      # Bootstrap (clone + basic setup)
./install.sh      # Full installation with package management
```

### Platform-Specific Package Installation
- **macOS**: Uses Homebrew (`brew install`)
- **Ubuntu**: Uses apt-get with platform-specific package mapping
- **Package Files**: `packages/base.packages` and `packages/dev.packages` with platform overrides

## Development Workflows

### Container Development

**Base Container** (`devcontainers/base/`):
- Ubuntu-based with essential development tools
- Pre-installed: stow, zoxide, ripgrep, bat, fzf, eza, git
- Custom user setup with proper permissions

**Dev Container** (`devcontainers/dev/`):
- Extends base container with full atelier installation
- Branch-specific cloning capability
- Automated dotfile linking via stow

## Code Architecture & Standards

### Shell Script Guidelines
- **Error Handling**: Use `set -e` for fail-fast behavior
- **Quoting**: Proper variable quoting to handle paths with spaces
- **Functions**: Source `install/common.sh` for shared utilities
- **Platform Detection**: Automatic macOS/Ubuntu package resolution
- **Logging**: Standardized `print_step/error/warning/info` functions

### Directory Structure
```
install/
├── common.sh          # Shared utility functions
├── install-arch.sh    # Arch Linux specific installer
├── install-mac.sh     # macOS specific installer

config/
└── .config/           # XDG-compliant application configurations

devcontainers/
├── base/              # Base development container
└── dev/               # Full atelier development container

packages/
├── base.packages      # Core tools (fzf, ripgrep, bat, etc.)
└── dev.packages       # Development tools (neovim, lazygit, etc.)
```

### Package Management System

**Format**: `package_name platform:override_name`
**Examples**:
- `bat ubuntu:batcat` - Install 'bat' on macOS, 'batcat' on Ubuntu
- `gh arch:github-cli` - Install 'gh' on macOS/Ubuntu, 'github-cli' on Arch
- `neovim` - Install 'neovim' on all platforms

## Build & Test Commands

### Installation Testing
```bash
# Full bootstrap test
bash boot.sh && ./install.sh

# Container testing
cd devcontainers/base && docker build .
cd devcontainers/dev && docker build .

# Configuration validation
stow --simulate --target=$HOME config/.config
```

### Development Testing
```bash
# Test package parsing
source install/common.sh
read_packages_for_platform packages/dev.packages ubuntu
```

## Development Patterns

### Container-First Development
- **Reproducible Environments**: Consistent development containers across teams
- **Branch-Specific Builds**: Dynamic container builds from specific repository branches
- **Automated Setup**: Self-configuring containers with dotfiles integration
- **Layered Architecture**: Base containers with specialized development overlays

### Cross-Platform Compatibility
- **Package Abstraction**: Platform-agnostic package definitions with overrides
- **Path Handling**: XDG-compliant configuration management
- **Tool Standardization**: Consistent CLI tool experience across macOS/Linux
- **Installation Automation**: Single-command environment replication

## Debugging & Troubleshooting

### Common Issues
- **SSH Key Configuration**: Ensure passwordless SSH access to remote hosts
- **Stow Conflicts**: Remove existing dotfiles before initial stow execution
- **Package Dependencies**: Verify Homebrew (macOS) or apt-get (Ubuntu) functionality
- **Container Permissions**: Check user/group ID mapping in devcontainer configurations

### Diagnostic Commands
```bash
# Check SSH connectivity
ssh -T workstation

# Validate stow simulation
cd config && stow --simulate --target=$HOME .

# Test package resolution
source install/common.sh && read_packages_for_platform packages/base.packages $(uname -s | tr '[:upper:]' '[:lower:]')

# Container health check
docker run --rm jeremytondo/atelier-dev:latest whoami
```

This architecture enables efficient remote development workflows while maintaining consistent, reproducible environments across different platforms and deployment scenarios.