# Implementation Plan - Refactor Dotfiles

## Phase 1: Preparation & Shell Integration
- [ ] Task: Create `config/zshrc.local.template` with `ATELIER_MACHINE_NAME` placeholder.
- [ ] Task: Update `config/.zshrc` to source `~/.zshrc.local` if it exists.
- [ ] Task: Conductor - User Manual Verification 'Preparation & Shell Integration' (Protocol in workflow.md)

## Phase 2: Directory Restructuring
- [ ] Task: Create new package directories: `config/common`, `config/workstation`, `config/mac`, `config/ubuntu`.
- [ ] Task: Move general configuration (git, nvim, zsh, etc.) into `config/common`.
- [ ] Task: Verify structure and ensure no files were lost during the move.
- [ ] Task: Conductor - User Manual Verification 'Directory Restructuring' (Protocol in workflow.md)

## Phase 3: Utility Scripts
- [ ] Task: Implement `scripts/status.sh` to show machine name and detect orphans/broken links.
- [ ] Task: Implement `scripts/clean.sh` to remove broken symlinks.
- [ ] Task: Implement `scripts/add.sh` to adopt local configs into `common`.
- [ ] Task: Conductor - User Manual Verification 'Utility Scripts' (Protocol in workflow.md)

## Phase 4: Deployment Logic Update
- [ ] Task: Refactor `install/dotfiles.sh` to use the new package structure.
- [ ] Task: Implement logic to source `ATELIER_MACHINE_NAME` and stow the corresponding package.
- [ ] Task: Ensure all `stow` commands use `--no-folding` and `-R`.
- [ ] Task: Conductor - User Manual Verification 'Deployment Logic Update' (Protocol in workflow.md)
