#!/bin/bash

set -ouex pipefail
pacman -Syu --noconfirm

# Prepare build enviroment
pacman -Sy --needed --noconfirm base-devel git paru
useradd -m build 2>/dev/null
echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir -p ./build_tmp
chown build:build ./build_tmp

# Speed up downloads
sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf

install_aur() {
    sudo -u build paru -S --noconfirm "$1"
}

build_spacefin_package() {
    cd ./build_tmp
    
    sudo -u build curl -L -O https://raw.githubusercontent.com/ExistingPerson08/"$1"/main/PKGBUILD
    sudo -u build makepkg -si --noconfirm
    sudo -u build rm -f PKGBUILD
    sudo -u build rm -rf "$1"-git
    sudo -u build rm -rf "$1"
    sudo -u build rm -rf pkg
    sudo -u build rm -rf src

    cd ..
}

pacman -R --noconfirm linux
pacman -S --noconfirm linux-zen linux-zen-headers

# Install de specific packages
case "$1" in
    "cosmic")
        DE_NAME="main"
        # Install Cosmic
        sudo pacman -S --noconfirm \
            cosmic-app-library \
            cosmic-applets \
            cosmic-bg \
            cosmic-comp \
            cosmic-files \
            cosmic-greeter \
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
            cosmic-text-editor \
            cosmic-wallpapers \
            cosmic-workspaces \
            gnome-keyring \
            xdg-user-dirs-gtk \
            xdg-desktop-portal \
            xdg-desktop-portal-gtk \
            xdg-desktop-portal-cosmic

        systemctl enable cosmic-greeter
        ;;
    "gnome")
        DE_NAME="gnome"

        # Setup GNOME
        pacman -S --noconfirm gnome-shell gnome-session gdm nautilus gnome-control-center gnome-bluetooth-3.0

          pacman -S --noconfirm \
          nautilus-python \
          nautilus-open-any-terminal \
          nautilus-share \
          gnome-shell-extension-appindicator \
          gnome-shell-extension-gsconnect \
          gnome-shell-extension-compiz-windows-effect-git \
          gnome-shell-extension-blur-my-shell \
          gnome-shell-extension-caffeine \
          gnome-shell-extension-logo-menu \
          gnome-shell-extension-pop-shell-git \
          ulauncher \
          papers \
          loupe \
          decibels \
          gnome-text-editor

        install_aur gnome-shell-extension-just-perfection-desktop        

        systemctl enable gdm
        ;;
    "niri")
        DE_NAME="niri"

        # Install and setup niri
        pacman -S --noconfirm niri-git dms-shell-git mate-polkit wl-clipboard dgop matugen sddm

        # Install aditional packages and dependencies
        pacman -S --noconfirm \
            nm-connection-editor \
            nautilus \
            nautilus-share \
            nautilus-python \
            nautilus-open-any-terminal \
            sddm-astronaut-theme \
            papers \
            khal \
            cava \
            qt6-multimedia \
            decibels \
            shotwell \
            wl-mirror \
            libnotify \
            gnome-keyring \
            xdg-desktop-portal-gtk \
            xdg-desktop-portal-gnome \
            xwayland-satellite \

        # Install AUR packages
        install_aur dsearch-git

        systemctl enable --global dms dsearch
        systemctl enable sddm
        ;;
esac

# Install edition specific packages
case "$2" in
    "main")
        # Skipping
        IMAGE_NAME="$DE_NAME"
        ;;
esac

# Ananicy Cpp
pacman -S --noconfirm ananicy-cpp cachyos-ananicy-rules-git
systemctl enable ananicy-cpp

# Install additional packages
pacman -S --noconfirm \
    zram-generator \
    fastfetch \
    adw-gtk-theme \
    thefuck \
    xorg-xrdb \
    upower \
    ufw \
    fish \
    zsh \
    just \
    duperemove \
    ddcutil \
    gnome-disk-utility \
    ghostty \
    jdk-openjdk \
    bazaar-git \
    docker \
    docker-compose \
    flatpak-builder \
    quickemu \
    waydroid \
    tailscale \
    restic \
    rclone \
    python-pip \
    python-requests \
    fprintd \
    ttf-liberation \
    noto-fonts \
    inter-font \
    ttf-dejavu \
    borg

systemctl enable tailscaled.service
systemctl enable ufw

# Build spacefin packages
build_spacefin_package ExistingRules
build_spacefin_package Spacefin-cli

# Temporary: Steam and dykscord on all images
pacman -S --noconfirm \
    steam \
    vesktop

pacman -S --noconfirm gnome-backgrounds archlinux-wallpaper

# Setup zram
echo -e '[zram0]\nzram-size = min(ram / 2, 8192)\ncompression-algorithm = zstd\nswap-priority = 100' > /usr/lib/systemd/zram-generator.conf

systemctl disable waydroid-container.service

# Write image info
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_VENDOR="existingperson08"
image_flavor="main"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"
HOME_URL="https://github.com/ExistingPerson08/Spacefin"

mkdir /usr/share/ublue-os/
touch $IMAGE_INFO
cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$image_flavor",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag":"latest",
  "base-image-name": "archlinux",
}
EOF

echo "spacefin" | tee "/etc/hostname"

sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Spacefin\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Spacefin\"|
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"Forty-Three\"|
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:existingperson08:spacefin\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="spacefin"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

# Workaround to make nix and snaps work
# They are not installed by default
mkdir /nix
mkdir /snap

systemd-sysusers --root=/
systemd-tmpfiles --root=/ --create --prefix=/var/lib/polkit-1

# Cleanup
userdel -r build
sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers
        pacman -Rns --noconfirm base-devel paru
pacman -Scc --noconfirm

rm -rf \
    ./build_tmp \
    /tmp/* \
    /var/cache/pacman/pkg/*

# Finalize
rm -rf /tmp/* || true
# find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \; Add when sure that it doesn't break image
find /var/cache/* -maxdepth 0 -type d \! -name lib \! -name rpm-ostree -exec rm -fr {} \;
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

dracut --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"
