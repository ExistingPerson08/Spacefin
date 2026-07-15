#!/bin/bash

set -ouex pipefail

# Generate fonts
find /etc/fonts/conf.d/ -xtype l -delete
locale-gen
fc-cache -frv

# Remove nano (swaped with micro) and sudo (swaped with run0) and wpa_supplicant (swapped with iwd)
pacman -R --noconfirm nano sudo
pacman -Rdd --noconfirm wpa_supplicant
rm /usr/bin/su

# Cleanup
pacman -Scc --noconfirm

rm -rf \
    ./build_tmp \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /usr/lib/sysimage/cache/pacman/pkg/*+

# Finalize
rm -rf /tmp/* || true
# find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \; Add when sure that it doesn't break image
find /var/cache/* -maxdepth 0 -type d \! -name lib \! -name rpm-ostree -exec rm -fr {} \;
mkdir -p /var/tmp
chmod -R 1777 /var/tmp
