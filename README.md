# Atelier
Opinionated development environment setup and management

## Overview
I do a lot of development on remote VMs and I wanted a way to quickly and easily
setup a development environment on a new machine. I was inspired by [Omakub](https://github.com/basecamp/omakub)
and essentially copied a lot of it to get this up and running. All of the setup
and config reflects how I like having my development environment set up.

## Install
Run the following script and then reboot.
```bash
wget -qO- https://raw.githubusercontent.com/jeremytondo/atelier/main/boot.sh | bash
```

## Config (dotfiles)
The config directory contains the dotfiles used to configure all of
the applications. GNU Stow is used to create and manage symlinks that
ensure these files are placed properly in the home directory. The organization
of this folder mimics the exact structure that will be replicated within the
home directory.
