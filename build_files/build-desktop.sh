#!/bin/bash

set -ouex pipefail

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
pacman -S --noconfirm niri dms-shell dms-shell-niri mate-polkit wl-clipboard dgop matugen quickshell

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
    ddcutil \
    gnome-disk-utility \
    flatpak-builder \
    ghostty \
    ufw \
    blueman \
    zed \
    xdotool
