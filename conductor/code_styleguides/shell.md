# Shell Style Guide

## General Principles
- **Use ShellCheck:** Always run `shellcheck` on scripts to identify common errors and pitfalls.
- **Portability:** Use `#!/usr/bin/env bash` or `#!/usr/bin/env zsh` for better portability across different systems.
- **Fail Fast:** Use `set -euo pipefail` at the beginning of scripts to ensure they exit on errors, undefined variables, or pipe failures.

## Naming Conventions
- **Files:** Use kebab-case for script filenames (e.g., `install-mac.sh`).
- **Variables:** Use `UPPER_CASE` for environment variables and global constants. Use `snake_case` for local variables.
- **Functions:** Use `snake_case` for function names.

## Best Practices
- **Localization:** Use the `local` keyword for all variables inside functions to avoid polluting the global namespace.
- **Quoting:** Always quote variables (e.g., `"$variable"`) to prevent word splitting and globbing issues.
- **Functions over Logic:** Encapsulate complex logic into functions with descriptive names.
- **No Custom Logging:** Stick to standard `echo` or `printf` for output to keep scripts lightweight and predictable.
