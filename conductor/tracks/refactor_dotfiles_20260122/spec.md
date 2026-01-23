# Specification: Modular Dotfiles Refactor

## Context
The current configuration setup needs to be refactored to support a modular, package-based approach. This will allow for machine-specific configurations (Workstation, Mac-Home, Mac-Work, Cloudtop) while maintaining a core set of common dotfiles. The critical constraint is that GNU Stow must *never* fold directories; it must always symlink individual files to prevent data loss and ensure clean overrides.

## Goals
1.  **Modular Structure:** Split `config/.config` into logical packages: `common`, `workstation`, `mac`, `ubuntu`.
2.  **No-Folding Enforcement:** Ensure all Stow operations use `--no-folding`.
3.  **Local Identity:** Implement a `~/.zshrc.local` pattern for machine-specific environment variables.
4.  **Management Scripts:** Create utility scripts (`status.sh`, `clean.sh`, `add.sh`) to manage the configuration.
5.  **Smart Deployment:** Update installation scripts to dynamically load packages based on the machine identity.

## Technical Requirements

### 1. Directory Restructuring
-   Refactor `config/` to support multiple packages.
-   **Proposed Structure:**
    ```
    config/
    ├── common/          # Shared configs (nvim, git, zsh)
    │   └── .config/
    ├── workstation/     # Workstation-specific tools
    │   └── .config/
    ├── mac-home/             # macOS-specific tools (aerospace, skhd)
    │   └── .config/
    ```

### 2. Shell Integration
-   **File:** `config/.zshrc` (to be moved to `config/common/.zshrc` or similar)
-   **Requirement:** Add a conditional block at the top:
    ```bash
    [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
    ```
-   **Template:** Create `config/zshrc.local.template` setting `ATELIER_MACHINE_NAME`.

### 3. Utility Scripts
All scripts must be in `scripts/` and use standard `echo` for output.

-   **`scripts/status.sh`:**
    -   Print `ATELIER_MACHINE_NAME`.
    -   List "orphan" files in `~/.config` (real files that should be symlinks).
    -   List broken symlinks.
-   **`scripts/clean.sh`:**
    -   Remove broken symlinks in `~/.config`.
-   **`scripts/add.sh <config_name>`:**
    -   Adopt a local directory into the `common` package using `stow --adopt`.

### 4. Deployment Logic (`install/dotfiles.sh`)
-   Logic must be idempotent.
-   **Step 1:** Source `~/.zshrc.local` (if present) to get `ATELIER_MACHINE_NAME`.
-   **Step 2:** Stow `common` with `--no-folding -R`.
-   **Step 3:** If `ATELIER_MACHINE_NAME` matches a package directory, stow that package with `--no-folding -R`.

## Non-Goals
-   We are not changing the *content* of the configuration files themselves (e.g., neovim plugins), only their *organization* and *deployment*.
