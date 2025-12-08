# Atelier Development Environment - Agent Guidelines

## System Overview

Atelier is a comprehensive development environment management system designed to provide a consistent, reproducible, and efficient development experience across various platforms and scenarios. It offers a suite of features including:

- **Dotfiles Management**: Automated configuration synchronization using GNU Stow for consistent settings across environments.
- **Cross-Platform Setup**: Streamlined tool installation and configuration across macOS (Homebrew), Arch Linux, and Ubuntu (apt) for consistent dev container environments.
- **Remote Development**: An elegant SSH-based workflow utilizing Shpool for persistent sessions, enabling seamless remote work and FZF-powered project discovery and management for quick and efficient navigation within your codebase without traditional terminal multiplexers.
- **Containerized Environments**: Support for reproducible development containers with devcontainers, facilitating isolated and consistent project setups.

## Core Components

### Atelier Scripts (`scripts/atelier*`)

The atelier command suite provides a unified interface for remote development:

- **`atelier`**: Main entry point for remote operations (`atelier <location> <action>`)
- **`atelier-launcher`**: Interactive FZF-based project launcher with live SSH location discovery
- **`atelier-locations`**: Location discovery service (zoxide integration + filesystem scanning)
- **`atelier-remote`**: Remote session manager using Shpool for persistence

### Key Features

**Session Management**: Uses Shpool instead of tmux/zellij for lightweight, persistent sessions
**Live Discovery**: Real-time project location fetching via SSH with smart caching
**Window Titles**: Automatic terminal title updates for clear workspace identification
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

### Remote Development Setup

1. **SSH Configuration**: Set `HOST="workstation"` in atelier scripts
2. **Remote Scripts**: Deploy atelier scripts to `~/.local/bin/` on remote host
3. **Session Types**:
   - `edit`: Launch Neovim in project directory
   - `opencode`: Start OpenCode for AI-assisted development  
   - `shell`: Open interactive shell in project context

### Container Development

**Base Container** (`devcontainers/base/`):
- Ubuntu-based with essential development tools
- Pre-installed: stow, zoxide, ripgrep, bat, fzf, eza, git
- Custom user setup with proper permissions

**Dev Container** (`devcontainers/dev/`):
- Extends base container with full atelier installation
- Branch-specific cloning capability
- Automated dotfile linking via stow

### Project Navigation

**Fast Mode** (default): Uses zoxide for frecency-based suggestions
**All Mode** (`-all` flag): Deep filesystem scan (3-level directory traversal)
**FZF Integration**: Fuzzy finding with action selection (edit/shell/opencode)

## Code Architecture & Standards

### Shell Script Guidelines
- **Error Handling**: Use `set -e` for fail-fast behavior
- **Quoting**: Proper variable quoting to handle paths with spaces
- **Functions**: Source `scripts/common.sh` for shared utilities
- **Platform Detection**: Automatic macOS/Ubuntu package resolution
- **Logging**: Standardized `print_step/error/warning/info` functions

### Directory Structure
```
scripts/
├── atelier*           # Main atelier command suite
├── common.sh          # Shared utility functions
├── install-arch.sh    # Arch Linux specific installer

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
# Test atelier scripts locally
source config/.zshrc
./scripts/atelier-launcher

# Test package parsing
source scripts/common.sh
read_packages_for_platform packages/dev.packages ubuntu
```

### Remote Development Testing
```bash
# Test SSH connectivity and remote script deployment
ssh workstation "~/.local/bin/atelier-locations"
ssh workstation "~/.local/bin/atelier-remote ~/projects/test shell"
```

## Development Patterns

### SSH-Based Remote Development
- **No Terminal Multiplexers**: Direct SSH with Shpool for session persistence
- **Live Location Discovery**: Real-time project scanning via SSH
- **Window Management**: Terminal title updates for workspace awareness
- **Action-Oriented**: Context-aware command execution (edit/shell/opencode)

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
source scripts/common.sh && read_packages_for_platform packages/base.packages $(uname -s | tr '[:upper:]' '[:lower:]')

# Container health check
docker run --rm jeremytondo/atelier-dev:latest whoami
```

This architecture enables efficient remote development workflows while maintaining consistent, reproducible environments across different platforms and deployment scenarios.