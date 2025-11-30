# Atelier Devcontainer

A minimal devcontainer configuration that includes standard CLI tools and dotfiles from the Atelier project.

## Features

- Based on Ubuntu 22.04 LTS
- Includes essential development tools (fzf, zoxide, ripgrep, bat, etc.)
- Automatically sets up dotfiles from the Atelier repository
- Uses zsh as the default shell
- Clean, maintainable configuration with external setup script

## How It Works

This devcontainer setup uses a two-file approach:

1. **devcontainer.json**: Configuration file for the devcontainer
2. **setup.sh**: External script that handles all post-creation tasks

This approach makes the configuration cleaner and more maintainable by separating the configuration from the setup logic.

## Usage

1. Copy both files to your project's `.devcontainer` directory:

```bash
mkdir -p /path/to/your/project/.devcontainer
cp -r ~/.local/share/atelier/devcontainer/.devcontainer/* /path/to/your/project/.devcontainer/
```

2. Open your project with a devcontainer-compatible tool or use the devcontainer CLI:

```bash
cd /path/to/your/project
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
```

## Customizing for Different Projects

You can easily extend this configuration for different project types by adding features to the `features` section:

### Example: Adding Node.js Support

```json
"features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
        "installZsh": true,
        "configureZshAsDefaultShell": true,
        "installOhMyZsh": false,
        "username": "devuser"
    },
    "ghcr.io/rocker-org/devcontainer-features/apt-packages:1": {
        "packages": "stow,fzf,zoxide,ripgrep,bat,fd-find,wget,neovim,tldr,gh"
    },
    "ghcr.io/devcontainers/features/node:1": {
        "version": "lts"
    }
}
```

### Example: Adding Python Support

```json
"features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
        "installZsh": true,
        "configureZshAsDefaultShell": true,
        "installOhMyZsh": false,
        "username": "devuser"
    },
    "ghcr.io/rocker-org/devcontainer-features/apt-packages:1": {
        "packages": "stow,fzf,zoxide,ripgrep,bat,fd-find,wget,neovim,tldr,gh"
    },
    "ghcr.io/devcontainers/features/python:1": {
        "version": "3.10"
    }
}
```