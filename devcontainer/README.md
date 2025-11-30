# Atelier Devcontainer

A minimal devcontainer configuration that includes standard CLI tools and dotfiles from the Atelier project.

## Features

- Based on the latest Ubuntu LTS release
- Includes essential development tools (fzf, zoxide, ripgrep, bat, eza, etc.)
- Automatically sets up dotfiles from the Atelier repository
- Uses zsh as the default shell
- Clean, minimal configuration

## Usage

1. Copy the `devcontainer.json` file to your project's `.devcontainer` directory:

```bash
mkdir -p /path/to/your/project/.devcontainer
cp devcontainer.json /path/to/your/project/.devcontainer/
```

2. Open your project in a devcontainer-compatible editor (VS Code with Remote Containers extension, GitHub Codespaces, etc.)

3. The devcontainer will automatically:
   - Install required packages
   - Set up zsh as the default shell
   - Clone your Atelier repository
   - Configure your dotfiles using stow

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
        "packages": "stow,fzf,zoxide,ripgrep,bat,eza,fd-find,wget,neovim,tldr,gh"
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
        "packages": "stow,fzf,zoxide,ripgrep,bat,eza,fd-find,wget,neovim,tldr,gh"
    },
    "ghcr.io/devcontainers/features/python:1": {
        "version": "3.10"
    }
}
```