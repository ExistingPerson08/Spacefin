#!/bin/bash

set -ouex pipefail

IMAGE_NAME="desktop"

# Install Cosmic
pacman -S --noconfirm \
    cosmic-app-library \
    cosmic-applets \
    cosmic-bg \
    cosmic-comp \
    cosmic-idle \
    cosmic-launcher \
    cosmic-notifications \
    cosmic-osd \
    cosmic-panel \
    cosmic-randr \
    cosmic-screenshot \
    cosmic-session \
    cosmic-settings \
    cosmic-settings-daemon \
    cosmic-wallpapers \
    cosmic-workspaces \

pacman -Rdd --noconfirm cosmic-files

# Install and setup niri
pacman -S --noconfirm niri dms-shell-git mate-polkit wl-clipboard dgop matugen quickshell

# Install aditional packages and dependencies
pacman -S --noconfirm \
    nm-connection-editor \
    nautilus \
    nautilus-share \
    nautilus-python \
    ghostty-nautilus \
    gvfs \
    gvfs-mtp \
    gvfs-smb \
    gvfs-wsdd \
    cava \
    qt6-multimedia \
    wl-mirror \
    libnotify \
    gnome-keyring \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-cosmic \
    xdg-user-dirs-gtk \
    xwayland-satellite \
    pavucontrol \
    quickemu \
    ddcutil \
    gnome-disk-utility \
    flatpak-builder \
    ghostty \
    ufw \
    blueman \
    zed \
    xdotool

# Ananicy Cpp
pacman -S --noconfirm ananicy-cpp cachyos-ananicy-rules-git
systemctl enable ananicy-cpp

# UFW config
ufw default deny
ufw allow CIFS
ufw allow 9300

systemctl enable --global dsearch dms
systemctl --global add-wants niri.service dms
systemctl enable greetd
