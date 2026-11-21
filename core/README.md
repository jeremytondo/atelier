# The Atelier core

The Atelier core is the part of Atelier that holds its logic and connects the other parts. Its first interface is the `atelier` command, a single Go binary for Linux and macOS.

So far it does three things:

- `atelier setup` sets up a machine for its user: a GitHub login, then the owner's dotfiles. A Linux machine with no SSH keys gets the GitHub account's, bare-metal machines join the tailnet, and Atelier for Linux machines take the `workstation` role. A Mac first installs Apple's Command Line Tools, for git. On Atelier for Linux, the image's `atelier-setup` bootstrap installs the core and runs it on first login. See [Setting up a new machine](../linux/README.md#setting-up-a-new-machine). On a Mac, `install.sh` does the same. See [Setting up a Mac](#setting-up-a-mac).
- `atelier os` shows and manages an Atelier for Linux machine's system through bootc: `update`, `channel` and `rollback`, each asking before it reboots. See [Updating a machine](../linux/README.md#updating-a-machine).
- `atelier version` prints the versions of the parts of Atelier on the machine: the core, and on Atelier for Linux, the image.

Run `atelier --help` for the details.

## Installing

Machines install and update the core through mise, from this repository's releases. The dotfiles list it:

```toml
"github:jeremytondo/atelier" = { version = "latest", version_prefix = "core/v", minimum_release_age = "0s" }
```

`version_prefix` picks the core's releases out from the Linux image's. `minimum_release_age` turns off mise's 24-hour hold on new releases, so a machine set up on the day of a release gets it. `mise upgrade` updates the core like any other tool.

The Linux image never contains the core, so there's only ever one copy on the PATH. Its bootstrap installs the core with `mise install` without writing the global config, and the dotfiles then adopt that installation.

## Setting up a Mac

On a new Mac, open a terminal and run:

```sh
curl -fsSL https://raw.githubusercontent.com/jeremytondo/atelier/main/core/install.sh | sh
```

`install.sh` does what `atelier-setup` does in the Linux image. It installs mise into `~/.local/bin`, then the core through mise, and hands off to `atelier setup`. Arguments go to `atelier setup`, after `sh -s --`, such as `| sh -s -- --dotfiles OWNER/REPO`.

Setup then does the following:

1. It installs Apple's Command Line Tools. macOS asks first, in a dialog on the Mac's screen, and setup waits until the install finishes. If the dialog is closed, `xcode-select --install` opens it again.
2. It logs in to GitHub with a device code: open the address it shows, or scan its QR code when `qrencode` is installed, and enter the code. gh keeps the login in the Keychain, or in a plain-text file when it can't (`gh auth status` says which), and git uses it over HTTPS.
3. It asks for the dotfiles repository, suggesting `<login>/dotfiles`.
4. It adopts the dotfiles, which install the tools, the core among them.

Unlike on Linux, setup adds no SSH keys to `~/.ssh/authorized_keys`, since a Mac is where SSH sessions start rather than where they arrive. It also leaves the login shell alone, since a Mac already uses zsh, and has no linger to turn on. A Mac has no role unless its owner chooses one in `~/.config/mise/miserc.local.toml`, and it doesn't join the tailnet: the Tailscale app does that. When setup finishes, it starts a new zsh login shell with the dotfiles in place. If it stops partway, run the same command again.

## Layout

| Path | Purpose |
| -- | -- |
| `cmd/atelier` | The command line. It only parses flags and talks to the terminal. |
| `internal/setup` | Setting up a machine, step by step |
| `internal/linux` | An Atelier for Linux machine's system: its versions, updates, channel and rollback |
| `internal/integrations/` | The programs and services the core drives: `mise`, `gh`, `bootc`, `tailscale`, `xcode` (Apple's Command Line Tools), and GitHub's device login (`github`) |
| `internal/command` | Running external programs |
| `internal/system` | The machine the core runs on |
| `internal/version` | The build's version |
| `install.sh` | Sets up a Mac: installs mise and the core, then runs `atelier setup` |

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
