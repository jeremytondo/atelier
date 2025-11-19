#!/bin/bash

# Check if a user with UID 1000 exists and delete them
if id -u "${USERUID}" &>/dev/null; then
  userdel -r "$(id -un "${USERUID}")"
fi

# Check if a group with GID 1000 exists and delete it
if getent group "${USERGID}" &>/dev/null; then
  groupdel "$(getent group "${USERGID}" | cut -d: -f1)"
fi

# Create user and group with specified USERUID and USERGID
groupadd --gid "${USERGID}" "${USERNAME}"
useradd -s /bin/bash --uid "${USERUID}" --gid "${USERNAME}" -m "${USERNAME}"

# Install base apps
source /tmp/install/main.sh

# Install additional apps
for app in /tmp/install/apps/*.sh; do source $app; done

# Generate the en_US.UTF-8 locale
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen &&
  locale-gen

# Set locale environment variables system-wide
echo "export LANG=en_US.UTF-8" >>/etc/profile
echo "export LANGUAGE=en_US:en" >>/etc/profile
echo "export LC_ALL=en_US.UTF-8" >>/etc/profile
