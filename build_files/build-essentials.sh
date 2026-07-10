#!/bin/bash

set -ouex pipefail

# Install additional packages
pacman -S --noconfirm \
    zram-generator \
    fastfetch \
    adw-gtk-theme \
    xorg-xrdb \
    upower \
    fish \
    just \
    iwd \
    eza \
    duperemove \
    jdk-openjdk \
    podman \
    podman-docker \
    restic \
    rclone \
    python-pip \
    python-requests \
    fprintd \
    ttf-liberation \
    noto-fonts \
    inter-font \
    ttf-dejavu \
    micro \
    nss-mdns \
    samba \
    fwupd \
    openssh \
    openvpn \
    networkmanager-openvpn \
    borg

pacman -S --noconfirm --ask=4 uutils-coreutils-git
pacman -S --noconfirm gnome-backgrounds archlinux-wallpaper

# Ananicy Cpp
pacman -S --noconfirm ananicy-cpp cachyos-ananicy-rules-git
systemctl enable ananicy-cpp

# Gaming stack: steam, vesktop & OGC gamescope-session
pacman -S --noconfirm \
    steam \
    vesktop \
    cachyos-v3/gamescope \
    chaotic-aur/faugus-launcher \
    chaotic-aur/gamescope-session-git \
    lib32-libdisplay-info
    #chaotic-aur/icoextract

# Systemd services
systemctl enable systemd-sysext
systemctl enable ufw
systemctl enable systemd-oomd
systemctl enable iwd
systemctl disable NetworkManager-wait-online.service
systemctl disable systemd-networkd.service
systemctl enable --global dsearch dms
systemctl --global add-wants niri.service dms
systemctl enable greetd
systemctl enable cups-browsed.service
systemctl enable cups.socket
