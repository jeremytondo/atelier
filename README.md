# Atelier

Opinionated development environment setup and management

## Overview

I do a lot of development on remote VMs and I wanted a way to quickly and easily
setup a development environment on a new machine. I also wanted to keep a similar
setup on my Mac. So, I wanted this to work on MacOS and Ubuntu.
I was inspired by [Omakub](https://github.com/basecamp/omakub)
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

## Atelier App

Bundled in the bin directory is a simple command line tool that can be used to
assist with managing projects and development environments.

### Projects

Projects are essentially folders contained in a designated projects directory. By
default it's set to HOME/projects. Opening a project means launching a basic tmux
setup for the specific project folder including a terminal window and a window with
Neovim opened for that project.

Projects can be managed using the `atelier project` command. This command will do
a couple different things based on the context.

* `atelier project` without any arguments will launch the latest project if any
are currently open, or it won't do anything at all.
* `atelier project [name]` including a project name will open that project if
it exists, or offer to help create a new one.

## To Do

