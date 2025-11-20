# Atelier Development Environment - Agent Guidelines

## Build/Test Commands

- **Install**: `bash boot.sh` (bootstrap) then `./install.sh` (full setup)
- **Test containers**: `cd containers/atelier-test && docker build .`
- **Single test**: Test individual components by sourcing shell scripts:
`source config/.zshrc`
- **Validation**: Check configurations with `stow --simulate` before applying

## Code Style Guidelines

- **Shell scripts**: Use `bash` shebang, proper quoting, error handling with
`set -e`
- **Shared functions**: Source `scripts/common.sh` for printing, file ops, use `print_step/error/warning`
- **Indentation**: 2 spaces for shell, follow existing patterns in each file type
- **Naming**: kebab-case for files/dirs, snake_case for shell variables,
ALL_CAPS for constants
- **Comments**: Use `#` for shell, document complex logic and file purposes
- **Error handling**: Always check exit codes, use descriptive error messages

## File Organization

- **Configs**: Place in `config/.config/[app]/` following XDG conventions
- **Scripts**: Root level for main scripts, shared utilities in `scripts/`
- **Shared functions**: Use `scripts/common.sh` for printing, file ops, utilities
- **Packages**: Add to appropriate `.packages` file with comments explaining purpose
- **Containers**: Separate Dockerfile per use case in `containers/`

## Development Workflow

- **Stow management**: Use GNU Stow for symlinking dotfiles, test with
`--simulate` first
- **Platform support**: Ensure scripts work on both macOS (Homebrew) and Ubuntu (apt)
- **Dependencies**: Add new tools to appropriate package list, document in README
- **Testing**: Use Docker containers for isolated testing of configurations
