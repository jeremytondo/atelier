#!/bin/sh
# Sets up a Mac: installs the Atelier core and hands off to `atelier setup`,
# which logs in to GitHub and adopts the owner's dotfiles. It does what
# atelier-setup does in the Linux image: installs mise, then the core through
# mise, without writing mise's global config, which the dotfiles bring.
#
#   curl -fsSL https://raw.githubusercontent.com/jeremytondo/atelier/main/core/install.sh | sh
#
# Arguments go to atelier setup, after `sh -s --`:
#
#   curl -fsSL .../core/install.sh | sh -s -- --dotfiles OWNER/REPO
#
# With --token-stdin, the token takes standard input, so the script can't:
#
#   gh auth token | ssh <host> 'sh -c "$(curl -fsSL .../core/install.sh)" - --token-stdin --dotfiles OWNER/REPO'
#
# Running it again picks up where it stopped.

# Everything is in a function, called on the last line, so a download that's
# cut short never runs half a script.
main() {
    set -eu

    # Atelier's Linux machines run Atelier for Linux, which sets itself up.
    if [ "$(uname -s)" != Darwin ]; then
        echo "Atelier's installer sets up a Mac. On Linux, install Atelier for Linux, which sets itself up at first login." >&2
        exit 1
    fi
    if [ "$(id -u)" = 0 ]; then
        echo "Run Atelier's installer as your own user, not root." >&2
        exit 1
    fi

    mise=$HOME/.local/bin/mise
    # The core is released from the Atelier repository with core/vX.Y.Z
    # tags, beside the Linux image's linux/vX.Y.Z. mise holds back releases
    # younger than a day unless told not to, and lists GitHub releases from
    # its mise-versions cache, which refreshes on a schedule. Asking GitHub
    # directly, without either, gets a new machine the newest core, even one
    # released minutes ago.
    core="github:jeremytondo/atelier[version_prefix=core/v]@latest"
    export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

    # When the script comes through a pipe, standard input is the script.
    # Nothing here reads it, and atelier setup asks its questions on the
    # terminal instead.
    token_stdin=0
    for arg in "$@"; do
        [ "$arg" != --token-stdin ] || token_stdin=1
    done

    echo "==> Install mise"
    if [ -x "$mise" ]; then
        echo "    mise is installed"
    else
        # Downloaded first, so a broken download never runs half a script.
        # Quiet drops its advice to edit ~/.zshrc, which the dotfiles handle.
        installer=$(mktemp)
        if ! curl -fsSL https://mise.run -o "$installer"; then
            rm -f "$installer"
            exit 1
        fi
        status=0
        MISE_QUIET=1 sh "$installer" </dev/null || status=$?
        rm -f "$installer"
        [ "$status" = 0 ] || exit "$status"
    fi

    echo "==> Install the Atelier core"
    MISE_USE_VERSIONS_HOST=false "$mise" install --minimum-release-age 0s "$core" </dev/null
    atelier=$("$mise" where "$core" </dev/null)/atelier
    if [ ! -x "$atelier" ]; then
        echo "Atelier's installer: can't find atelier in $core" >&2
        exit 1
    fi

    # A subshell tries the terminal: a redirection that fails on a builtin
    # such as : would end the whole script.
    if [ "$token_stdin" = 0 ] && [ ! -t 0 ] && (: </dev/tty) 2>/dev/null; then
        exec "$atelier" setup "$@" </dev/tty
    fi
    exec "$atelier" setup "$@"
}

main "$@"
