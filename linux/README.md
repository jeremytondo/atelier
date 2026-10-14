# Atelier for Linux

Atelier for Linux is a personal, headless, image-based Linux system for workstations and VMs, built on [Fedora bootc](https://docs.fedoraproject.org/en-US/bootc/). Machines run a released image, download new versions in the background, apply them when the developer chooses, and can roll back.

The image carries only the system. Development tools, mise itself, the [Atelier core](../core/README.md) and dotfiles live in the user's mise-managed environment. The one exception is a C toolchain, which mise can't provide. Machine details such as the hostname, user account and SSH keys come from provisioning: cloud-init on VMs, and the installer's questions on bare metal (see [Installing on bare metal](#installing-on-bare-metal)).

The image is public at `ghcr.io/jeremytondo/atelier-linux`. It must never contain secrets, user accounts, SSH keys or hostnames.

## What's in the image

On top of `quay.io/fedora/fedora-bootc:44`, which already has openssh-server, podman, toolbox, sudo and NetworkManager:

- **Packages:** git, zsh, libatomic, `xterm-ghostty` terminfo, Tailscale, cloud-init, qemu-guest-agent, distrobox, firewalld and qrencode.
- **Browser libraries:** the system libraries Playwright's Chromium needs, such as nss, at-spi2, cups-libs, libgbm, pango and fontconfig. Playwright downloads the browser itself into the user's home directory, so the image has no browser.
- **C toolchain:** gcc, g++, make and pkg-config, for building native code such as Rust crates. When a build needs a library's headers, add its `-devel` package to the `Containerfile`.
- **Shell:** zsh is the default login shell for new users.
- **First-login setup:** the `atelier-setup` bootstrap, and a login hook that starts it. See [Setting up a new machine](#setting-up-a-new-machine).
- **SSH:** key authentication only. Password authentication and root login are rejected.
- **SELinux:** enforcing, with `virt_qemu_ga_read_nonsecurity_files` on.
- **ptrace:** `kernel.yama.ptrace_scope = 1`.
- **Firewall:** the default zone (`public`) accepts SSH only. The Tailscale interface is in the `trusted` zone. VMs opt out through cloud-init.
- **Updates:** the bootc update timer downloads new versions but never applies them or reboots.
- **Root filesystem:** XFS, for disk images and `bootc install`. In VMs, it grows to fill the disk at boot.

cloud-init and qemu-guest-agent stay inactive on bare metal. Tailscale runs everywhere, but only bare-metal machines join the tailnet, during first-login setup. VMs stay off it.

Check which version a machine runs with `atelier version`, which also shows the Atelier core's version:

```console
$ atelier version
Atelier Core   v0.1.0
Atelier Linux  v0.2.1
```

Production images report `vX.Y.Z`. `dev` images report `dev-<commit>`. `atelier os` and `bootc status` show it too, and `grep IMAGE_VERSION /etc/os-release` works before setup has installed the core.

## Releases

Releases are cut by one GitHub Actions workflow, `Linux release`, dispatched from mise:

| Command | Result |
| -- | -- |
| `mise run linux:release:dev` | Builds `main` and pushes it as `:dev`. |
| `mise run linux:release:dev --ref <branch>` | Builds a pushed branch as `:dev`. |
| `mise run linux:release:patch` | Cuts the next patch release from `main`. |
| `mise run linux:release:minor` | Cuts the next minor release. |
| `mise run linux:release:major` | Cuts the next major release. |

A production release does the following:

1. It computes the next version from the repository's `linux/vX.Y.Z` tags.
2. It builds the image from that commit.
3. It builds a qcow2 disk image from it with [image-builder](https://github.com/osbuild/image-builder). It's built from a local `:stable` tag, so machines created from it track `:stable`. The file isn't wrapped in `.xz` or similar, so Proxmox can import it directly. Like Fedora's cloud images, it's compressed inside the qcow2 format.
4. It checks the qcow2 against GitHub's 2 GiB release-asset limit. Over the limit, the run fails before anything is published. From 90% of the limit, it warns. The run summary shows the size either way.
5. It tags the commit `linux/vX.Y.Z` and pushes the image as `:vX.Y.Z`.
6. It moves `:stable` to the new image.
7. It creates a GitHub Release with the qcow2 and its sha256 checksum.

`dev` builds produce no qcow2, git tag or GitHub Release.

Git tags carry the `linux/` prefix because each part of Atelier is released separately. Image tags and the version a machine reports don't, so they read `vX.Y.Z`.

Up to v0.1.7, this image was called AtelierOS. Those releases are `ghcr.io/jeremytondo/atelieros` and the plain `vX.Y.Z` git tags, and they're kept as they were. `linux/v0.2.0` is the first release under the new name.

A production release rebuilds the image from its commit rather than retagging `:dev`, so it may include Fedora updates newer than the last `dev` build.

Production tags, images and releases are never moved, edited or deleted. If a production run fails, re-run it: it resumes the same version rather than skipping to the next one.

Every Monday the workflow cuts a patch release from `main`, so Fedora's updates reach `:stable` without anyone remembering. GitHub disables scheduled workflows after 60 days without repository activity. If the weekly releases stop, re-enable `Linux release` in the Actions tab.

To check the image locally before releasing, run `mise run linux:build`. It builds with podman or docker and runs `bootc container lint`.

To check a qcow2, run `mise run linux:boot-test <qcow2>`. It boots a throwaway copy in qemu the way Proxmox would, then checks over SSH that it tracks `:stable`, that cloud-init finished cleanly, that the root grew to fill the disk, and the image's settings. It also checks that SSH commands and scp never start first-login setup, while a login with a terminal does. It needs qemu with KVM, xorriso and jq.

To run first-login setup for real as well, name the dotfiles repository:

```sh
BOOT_TEST_DOTFILES=jeremytondo/dotfiles mise run linux:boot-test <qcow2>
```

The VM's user then has the host's user name, since the dotfiles declare their owner's account. It logs in with the host's gh login, adopts the dotfiles, and checks that `atelier version` runs from the tools they list and names the image, and that `atelier os` reads bootc and names the booted version. These use the core release the dotfiles list, so a new core command is checked once it's released. The dotfiles' history watcher may push from the VM until it stops.

## Installing on bare metal

Each release includes an installer ISO, `atelier-linux-installer-vX.Y.Z.iso`. It's Fedora's netinstall ISO with a short kickstart built in. The kickstart only names the image, so Fedora's installer, Anaconda, installs Atelier for Linux and asks for everything else on its usual screens. Its screens say Fedora 44, since it's Fedora's installer.

1. Download the installer from the latest release. Write it to a USB stick, or attach it as virtual media through the machine's remote management.
2. Connect the machine to a wired network, and boot the installer with UEFI. After 10 seconds it starts **Install Atelier for Linux** on its own.
3. Choose a language, then fill in the summary:
   - **Installation Destination:** choose the disk. Automatic partitioning makes an EFI partition, `/boot` and one XFS root, like the qcow2. A disk that's already in use needs **Free up space** to make room.
   - **User Creation:** your user and password. Leave it an administrator, so it can use sudo.
   - **Network & Host Name:** the hostname. Otherwise it's `fedora`.
   - **Time & Date:** the timezone.

   Root stays disabled. Choose **Begin Installation**. The installer downloads `:stable`, about 1.3 GB, and installs it.
4. Choose **Reboot System**, and remove the stick or detach the ISO.
5. Log in at the console with your password. First-login setup starts. It logs in to GitHub, adds that account's SSH keys so SSH works from then on, and joins the machine to the tailnet.

The installed machine tracks `:stable`, like one made from the qcow2.

### Installing with no questions

For a machine installed by script, write a complete kickstart for it and build it into an installer ISO of its own:

```sh
mise run linux:kickstart --hostname ws1 --disk nvme0n1 --output ws1.ks
mise run linux:installer --kickstart ws1.ks --output ws1.iso
```

- `--disk` is the disk to erase, as the installer names it. No other disk is touched. A name from `/dev/disk/by-id`, such as `disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7KHNJ0X123456`, can't pick the wrong disk.
- `linux:kickstart` asks twice for the user's password, which is for sudo and the console. SSH takes keys only.
- The user is the one running the task. `--user` names another.
- The SSH keys are the ones on the GitHub account gh is logged in as. `--github LOGIN` names another account, and `--ssh-keys FILE` reads them from a file.
- The timezone is this machine's. `--timezone` names another.

The ISO installs as soon as it boots: it erases the disk, installs `:stable` and powers off. Detach it, then power on. Keep it to the machine it was made for. Both files hold the password's hash, so keep them out of the repository, and delete them once the machine is installed.

### Building the installer

A production release builds the installer with `mise run linux:installer --output <file>`. The task downloads Fedora's netinstall ISO once into `~/.cache/atelier` and checks it against its pinned checksum. `--fedora-iso` uses one already downloaded. The task runs Fedora's `mkksiso` in a privileged container, so it needs podman or docker.

The installer adds two things to Fedora's ISO:

- **`linux/installer/atelier.ks`**, the kickstart. It installs the image with Anaconda's `ostreecontainer` command, as [Fedora's bootc docs](https://docs.fedoraproject.org/en-US/bootc/bare-metal/) and Universal Blue's installers do. Fedora 44's newer `bootc` command writes no `/etc/fstab`, so `/boot` and `/home` aren't mounted, and it leaves the users' homes without SELinux labels.
- **`linux/installer/updates/`**, Anaconda's settings, added as an updates image. They make automatic partitioning lay out an EFI partition, `/boot` and one XFS root, the layout of Fedora's bootc docs and the qcow2. Fedora's default is btrfs, whose root options can't be applied to the image's composefs root, so `systemd-remount-fs` fails at every boot. Universal Blue sets the same Anaconda storage settings for its installers, in its own profile.

To check a change, run `mise run linux:install-test`. It builds an installer with a kickstart from `linux:kickstart`, and in qemu under UEFI, boots it with nothing else attached, the way a real machine does. It then boots the installed disk and checks it over SSH:

- that it tracks `:stable` and can check it for updates;
- the hostname, timezone and user;
- the home directory's SELinux labels, the sudo password and the locked root account;
- the XFS root on the named disk, `/boot` on its own partition and the EFI partition at `/boot/efi`;
- that no units failed, and that a second disk is left untouched.

It needs qemu with KVM, edk2's OVMF firmware, podman or docker, jq and openssl. Set `OVMF_CODE` and `OVMF_VARS` if the firmware isn't in `/usr/share/edk2/x64/`. The interactive screens aren't tested automatically. Check them by hand after changing `atelier.ks` or Anaconda's settings.

## Setting up a new machine

A new machine sets itself up the first time its user logs in interactively, over SSH or at the console. Setup gets two things from the owner: a GitHub login and the GitHub repository that holds their dotfiles, a mise setup repository. The dotfiles do everything else.

The image's `atelier-setup` is a short bootstrap. It installs what setup needs, then hands off to `atelier setup` from the [Atelier core](../core/README.md), which does the rest. Setup runs these steps:

1. The bootstrap installs mise in the home directory with mise's official installer, so `mise self-update` works.
2. It installs gh and the Atelier core through mise, without writing mise's global config. The dotfiles' entries for them then use these same installations.
3. It hands off to `atelier setup`, which logs gh in to GitHub.
4. If `~/.ssh/authorized_keys` has no keys, it adds the ones on the GitHub account. A machine from the installer starts with only a password, while VMs get keys from cloud-init.
5. On bare metal, it joins the machine to the tailnet with `tailscale up --qr`. VMs skip this step.
6. It asks for the dotfiles repository, as `OWNER/REPO` or a URL, and checks that it exists. It suggests `<your login>/dotfiles` when there is one, so Enter accepts it. The answer is kept in `~/.local/state/atelier/dotfiles` in case setup has to start again.
7. It turns on linger, so the dotfile history watcher runs without a login session.
8. It sets the login shell to zsh.
9. It adopts the dotfiles with `mise bootstrap --adopt <repo> --take-remote-all`, which also installs the tools they list. Where a starter file differs, such as Fedora's `~/.zshrc` or gh's `config.yml`, the dotfiles' version replaces it. On a machine that already adopted them, setup runs `mise bootstrap` instead.
10. It records that setup is done, in `~/.local/state/atelier/setup-done`, and starts a zsh login shell.

The core updates on its own schedule, through `mise upgrade`, rather than with the image.

On bare metal, setup shows a QR code for GitHub's device login, and a one-time code. Scan the QR code with your phone, enter the code and approve. Setup then continues on its own. If the code expires first, setup offers a new one.

Tailscale then shows a QR code of its own. Scan it and approve the machine in Tailscale to add it to the tailnet. Setup tells VMs from bare metal with `systemd-detect-virt`. If no one is at the terminal, as with `--token-stdin`, setup leaves the tailnet for later. Join then with `sudo tailscale up --qr`.

A VM can be set up with no prompts by handing it the workstation's gh login and naming the repository:

```sh
gh auth token | ssh <vm> atelier-setup --token-stdin --dotfiles jeremytondo/dotfiles
```

`--dotfiles` also skips the question in an interactive run. Without a terminal to ask on, setup needs it, and stops before changing anything if it's missing.

Setup never accepts a token as an argument or an environment variable, and never prints one. The token is stored only in gh's login file, `~/.config/gh/hosts.yml`.

If setup fails or is interrupted, it names the step that failed and leaves you in a plain shell. It starts again at the next interactive login, and skips the steps that already finished. You can also run `atelier-setup` by hand at any time. SSH commands, scp, sftp and remote editors never start it.

### Revoking GitHub access

Setup uses gh's own login, which covers all repositories and doesn't expire. VMs set up with `--token-stdin` share the workstation's token, so revoking it logs all of them out. A machine can get its own token with `gh auth login`.

- `gh auth logout` only removes the token from that machine. GitHub still accepts it.
- To revoke one token, run this on a machine that has it:

  ```sh
  gh auth token | jq -Rc '{credentials: [.]}' |
      curl -fsS -X POST https://api.github.com/credentials/revoke \
          -H 'Accept: application/vnd.github+json' --data @-
  ```

  GitHub's [credential-revocation endpoint](https://docs.github.com/en/rest/credentials/revoke) takes the token itself and no other authentication.
- To revoke every machine at once, revoke **GitHub CLI** in GitHub's settings, under **Applications** > **Authorized OAuth Apps**.

## Updating a machine

Machines follow `:stable`. Every 8 hours or so, the update timer downloads any newer version without applying it. `atelier os` shows what the machine runs:

```console
$ atelier os
Channel     stable
Booted      v0.2.1
Downloaded  v0.2.2
Rollback    v0.2.0
```

To apply the downloaded update, run:

```sh
atelier os update
```

When no update is waiting, it downloads one first. Then it asks before rebooting into the new version. `--reboot` reboots without asking. Without a terminal, as in `ssh <host> atelier os update`, it never reboots unless `--reboot` is given, and the new version starts at the next reboot. A downloaded update that's never applied is discarded at the next reboot and downloaded again afterwards.

Updates and rollbacks never touch home directories, mise tools or project files.

## Rolling back

To return to the previous version, run:

```sh
atelier os rollback
```

Like `update`, it asks before rebooting. The update timer then downloads the newer version again, and `atelier os update` would bring it back.

bootc keeps one previous version. To go back further, or to stay on an older version, switch to a specific release:

```sh
atelier os channel v1.2.3
```

That machine then stays on `v1.2.3`. Switch back to `stable` to resume updates.

## Switching channels

To test a `dev` build on one machine, run:

```sh
atelier os channel dev
```

To return to `:stable`, run:

```sh
atelier os channel stable
```

`atelier os channel` on its own shows the channel. A switch downloads the channel's image, then asks before rebooting into it, like `update`.

## Without the core

`atelier os` runs bootc through sudo. If the core is missing or broken, bootc does the same directly:

| Task | Command |
| -- | -- |
| See what the machine runs | `sudo bootc status` |
| Apply the downloaded update | `sudo bootc upgrade --from-downloaded --apply` |
| Download and apply an update | `sudo bootc upgrade --apply` |
| Roll back | `sudo bootc rollback --apply` |
| Switch channels | `sudo bootc switch --apply ghcr.io/jeremytondo/atelier-linux:<channel>` |

## Adding a system package

System packages are never installed on a running machine. dnf refuses to install on bootc anyway.

1. Add the package to the `dnf -y install` list in the `Containerfile`.
2. Run `mise run linux:build` to check that it builds and lints.
3. Commit and push, then run `mise run linux:release:dev`.
4. Switch a machine to `:dev` with `atelier os channel dev`, and check the change.
5. Run `mise run linux:release:patch`, and switch the test machine back to `:stable`.

Weak dependencies are left out of the image, since on a headless machine they're desktop pieces such as PipeWire and Vulkan drivers. If a package needs one of them, add it to the `Containerfile` by name. Watch the qcow2 size in the release summary: GitHub refuses release assets over 2 GiB.

For a one-off tool, use a distrobox container instead, for example an Arch container with the AUR. For a temporary experiment, `sudo bootc usr-overlay` makes `/usr` writable until the next reboot.

## Upgrading Fedora

A new Fedora major version is a change to the base tag in the `Containerfile`, for example from `fedora-bootc:44` to `fedora-bootc:45`.

1. Change the tag, and run `mise run linux:build`.
2. Release it to `:dev` and test it on one machine.
3. Point `linux/scripts/installer` at the new release's netinstall ISO: its Fedora version, name and checksum. Run `mise run linux:install-test`, and check the interactive install by hand.
4. Cut a production release. `mise run linux:release:minor` makes the jump visible in the version number.

Machines receive it through the normal update path. If the new version misbehaves, `atelier os rollback` returns to the previous Fedora.

## Files

Paths are from the repository root.

| Path | Purpose |
| -- | -- |
| `linux/Containerfile` | The image: packages, configuration and the release marker |
| `linux/system_files/` | Files copied into the image's root, including the `atelier-setup` bootstrap and its login hook |
| `linux/scripts/boot-test` | The qemu boot test behind `mise run linux:boot-test` |
| `linux/installer/` | The installer's kickstart and Anaconda's settings |
| `linux/scripts/installer` | Builds the installer ISO, behind `mise run linux:installer` |
| `linux/scripts/kickstart` | Writes a complete kickstart for one machine, behind `mise run linux:kickstart` |
| `linux/scripts/install-test` | The qemu install test behind `mise run linux:install-test` |
| `mise.toml` | The `linux:` build, test, installer and release tasks |
| `.github/workflows/linux-release.yml` | The release workflow and its weekly schedule |
