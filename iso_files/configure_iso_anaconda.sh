#!/usr/bin/env bash
set -eoux pipefail

# Remove packages to save space
dnf remove -y ublue-brew || true

# Disable services not needed in live environment
systemctl disable rpm-ostree-countme.service
systemctl disable bootloader-update.service

# Fix Anaconda WebUI
dnf install -y firefox

# Install Anaconda for installation
dnf install -y anaconda-live libblockdev-btrfs
