#!/bin/bash

set -ouex pipefail

# Install COSMIC desktop and exclude non-cosmic apps
dnf copr enable -y ryanabx/cosmic-epoch
dnf install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

# Install additional GNOME apps
# (native version is better than flatpak)
dnf install -y showtime gnome-firmware

# Remove unused Bluefin-dx apps
dnf remove -y sysprof

