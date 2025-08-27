#!/bin/bash

set -ouex pipefail

# Install COSMIC desktop and exclude non-cosmic apps
dnf copr enable -y ryanabx/cosmic-epoch
dnf install cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

# Remove unused Bluefin-dx apps
dnf remove -y sysprof

