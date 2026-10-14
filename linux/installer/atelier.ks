# The kickstart in Atelier for Linux's installer ISO. Fedora's installer,
# Anaconda, installs the image and asks for everything else on its usual
# screens: the disk, the user and password, the timezone and the hostname.

# ostreecontainer, as Fedora's bootc docs and Universal Blue use. Fedora 44's
# newer bootc command writes no /etc/fstab, so /boot and /home aren't
# mounted, and leaves the users' homes without SELinux labels. The image
# isn't signed, so there's no signature to check.
ostreecontainer --url=ghcr.io/jeremytondo/atelier-linux:stable --no-signature-verification
