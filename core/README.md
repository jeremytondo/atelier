# The Atelier core

The Atelier core is the part of Atelier that holds its logic and connects the other parts. Its first interface is the `atelier` command, a single Go binary for Linux and macOS.

So far it does two things:

- `atelier setup` sets up a Linux machine for its user: a GitHub login, then the owner's dotfiles. On Atelier for Linux, the image's `atelier-setup` bootstrap installs the core and runs it on first login. See [Setting up a new machine](../linux/README.md#setting-up-a-new-machine).
- `atelier version` prints the versions of the parts of Atelier on the machine: the core, and on Atelier for Linux, the image.

Run `atelier --help` for the details.

## Installing

Machines install and update the core through mise, from this repository's releases. The dotfiles list it:

```toml
"github:jeremytondo/atelier" = { version = "latest", version_prefix = "core/v", minimum_release_age = "0s" }
```

`version_prefix` picks the core's releases out from the Linux image's. `minimum_release_age` turns off mise's 24-hour hold on new releases, so a machine set up on the day of a release gets it. `mise upgrade` updates the core like any other tool.

The Linux image never contains the core, so there's only ever one copy on the PATH. Its bootstrap installs the core with `mise install` without writing the global config, and the dotfiles then adopt that installation.

## Layout

| Path | Purpose |
| -- | -- |
| `cmd/atelier` | The command line. It only parses flags and talks to the terminal. |
| `internal/setup` | Setting up a machine, step by step |
| `internal/integrations/` | The programs and services the core drives: `mise`, `gh`, and GitHub's device login (`github`) |
| `internal/command` | Running external programs |
| `internal/system` | The machine the core runs on |
| `internal/version` | The build's version |

The logic lives in packages that know nothing about flags or terminal output, so later interfaces, such as a service or an API, don't need a rewrite.

## Tasks

Run from anywhere in the repository:

| Command | Result |
| -- | -- |
| `mise run core:build` | Builds `core/bin/atelier`. |
| `mise run core:test` | Runs `go vet` and the tests, with the race detector. |
| `mise run core:release:patch` | Cuts the next patch release from `main`. |
| `mise run core:release:minor` | Cuts the next minor release. |
| `mise run core:release:major` | Cuts the next major release. |

The `Core check` workflow runs the tests and the build on pull requests that touch the core.

## Releases

Releases are cut by the `Core release` workflow, which the `core:release:*` tasks dispatch. A release does the following:

1. It runs the tests.
2. It computes the next version from the repository's `core/vX.Y.Z` tags. The first release is `core/v0.1.0`.
3. It builds `atelier` for Linux and macOS on amd64 and arm64, stamped with the version.
4. It tags the commit `core/vX.Y.Z`.
5. It creates a GitHub Release with an archive per platform, `atelier_<os>_<arch>.tar.gz`, and `checksums.txt`.

Releases must stay full releases with the binaries attached, since mise skips prereleases and releases without assets. The binary reports `vX.Y.Z`, without the `core/` prefix. Builds the workflow didn't make report `devel-<commit>`.

Tags and releases are never moved, edited or deleted. If a run fails, re-run it: it resumes the same version rather than skipping to the next one.

mise reads only the newest 100 releases of the repository. With weekly Linux releases, `latest` would stop finding the core only after about two years without a core release. Pinned versions always work.
