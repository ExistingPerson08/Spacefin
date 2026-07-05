#!/bin/bash

set -ouex pipefail
pacman -Syu --noconfirm
pacman -S --noconfirm git

# Speed up downloads
sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf

# Build system
/ctx/build-desktop.sh
/ctx/from-source/install-aur.sh
/ctx/from-source/install-rules.sh
/ctx/from-source/install-bazaar.sh
/ctx/build-essentials.sh
/ctx/build-config.sh
/ctx/finalize.sh

dracut --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"
