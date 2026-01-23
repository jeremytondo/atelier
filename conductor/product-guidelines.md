# Product Guidelines

## Automation & Scripting
- **Modular Shell Scripts:** Use Bash/Zsh scripts organized by task (e.g., `install-mac.sh`, `docker.sh`) to keep logic simple, portable, and easy to debug.
- **Output:** Use standard `echo` for script output. Avoid custom install-script logging functions to maintain simplicity and compatibility.

## Tool & Component Management
- **Inclusion by Default:** Core tools essential to the "Atelier experience" (e.g., Neovim, Zsh) are included in the base installation to ensure immediate functionality.
- **Modular Components:** Additional tools should be categorized (e.g., `additional-tools/`) and installed only if relevant to the platform or explicitly requested.

## Configuration Management (Dotfiles)
- **Modular Packages:** Configuration should be structured into logical "packages" (e.g., `common`, `workstation`, `mac`) to allow granular control over what gets installed on each machine.
- **Individual Symlinking (No-Folding):** All symlinking operations MUST preserve `~/.config` as a physical directory containing individual links. The "Tree Folding" behavior (linking the entire parent directory) is strictly prohibited to prevent conflicts and data loss.
- **Local Identity:** Machine-specific environment variables (like `ATELIER_MACHINE_NAME`) must be defined in a local, untracked file (e.g., `~/.zshrc.local`) and never committed to the repository.
- **Adoption:** New configurations should be capable of being "adopted" from the local filesystem into the `common` package.

## Git & Version Control
- **Commit Style:** Simple and freeform messages. Ensure descriptions are clear and concise.
- **Ignored Files:** Strictly adhere to `.gitignore` to prevent tracking of sensitive or session-specific data (e.g., `gh/hosts.yml`, `gcloud`, `github-copilot`).
