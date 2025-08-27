#!/bin/bash

set -ouex pipefail

case "$1" in
    "main")
        # Using tagged Cosmic desktop in main image
        dnf install -y @cosmic-desktop @cosmic-desktop-apps --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator
        ;;
    "exp")
        # Using latest (nightly) Cosmic desktop in exp image
        dnf copr enable -y ryanabx/cosmic-epoch
        dnf install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

        # Remove unused Bluefin-dx apps
        dnf remove -y sysprof
        ;;
esac

# Install additional GNOME apps
# (native version is better than flatpak)
dnf install -y showtime gnome-firmware


