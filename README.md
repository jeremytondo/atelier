# Atelier

Atelier makes development across many machines feel like one environment. A Mac is the control center, and the work runs wherever it's convenient: the Mac itself, a Linux workstation, or VMs.

This repository holds Atelier's parts. Each part has its own directory, README and release workflow.

| Part | Directory | What it is |
| -- | -- | -- |
| Atelier for Linux | [`linux/`](linux/README.md) | The image-based Linux system for workstations and VMs, built on Fedora bootc |
| The Atelier core | [`core/`](core/README.md) | The logic that connects the parts, used through the `atelier` command |

The Mac app will move here as its own part. Dotfiles stay in their own private repository, since they're personal settings rather than part of Atelier.

## Tasks

Tasks are run with [mise](https://mise.jdx.dev) from anywhere in the repository, and are named after their part. Run `mise tasks` to list them.

```sh
mise run linux:build
mise run core:test
```

Each part's README describes its tasks.
