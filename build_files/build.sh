#!/bin/bash

set -ouex pipefail
pacman -Syu --noconfirm

# Prepare build enviroment
pacman -S --needed --noconfirm base-devel git paru
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

    sudo -u build curl -L -O https://raw.githubusercontent.com/ExistingPerson08/"$1"/PKGBUILD
    sudo -u build makepkg -si --noconfirm
    sudo -u build rm -f PKGBUILD
    sudo -u build rm -rf "$1"-git
    sudo -u build rm -rf "$1"
    sudo -u build rm -rf pkg
    sudo -u build rm -rf src

    cd ..
}

# Install de specific packages
case "$1" in
    "desktop")
        IMAGE_NAME="desktop"
        # Install Cosmic
        pacman -S --noconfirm \
            cosmic-app-library \
            cosmic-applets \
            cosmic-bg \
            cosmic-comp \
            cosmic-files \
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
            khal \
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
            bazaar-git \
            quickemu \
            ddcutil \
            gnome-disk-utility \
            flatpak-builder \
            ghostty \
            blueman \
            xdotool

        # Install AUR packages
        install_aur dsearch-git
        install_aur greetd-dms-greeter-git
        install_aur wl-freeze-git

        # Ananicy Cpp
        pacman -S --noconfirm ananicy-cpp cachyos-ananicy-rules-git
        systemctl enable ananicy-cpp

        # Setup dms greeter
        printf '[terminal]\nvt = 1\n\n[default_session]\nuser = "greeter"\ncommand = "/usr/bin/dms-greeter --command niri"\n' | sudo tee /etc/greetd/config.toml

        systemctl enable --global dsearch dms
        systemctl --user add-wants niri.service dms
        systemctl enable greetd
        ;;
    "server")
        IMAGE_NAME="server"

        # Install snap
        install_aur snapd
        systemctl enable --now snapd.socket
        systemctl enable --now snapd.apparmor.service
        ln -s /var/lib/snapd/snap /snap

        pacman -S --noconfirm sway foot rofi
        ;;
esac

# Install additional packages
pacman -S --noconfirm \
    zram-generator \
    fastfetch \
    adw-gtk-theme \
    xorg-xrdb \
    upower \
    ufw \
    fish \
    zsh \
    just \
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

pacman -S --noconfirm gnome-backgrounds archlinux-wallpaper

# UFW config
ufw default deny
ufw allow CIFS

# Build spacefin packages
build_spacefin_package ExistingRules/main

# Gaming stack: steam, vesktop & OGC gamescope-session
pacman -S --noconfirm \
    steam \
    vesktop \
    waydroid \
    cachyos-v3/gamescope \
    chaotic-aur/faugus-launcher \
    chaotic-aur/gamescope-session-git \
    lib32-libdisplay-info
    #chaotic-aur/icoextract

# Systemd services
systemctl enable ufw
systemctl enable systemd-oomd
systemctl disable waydroid-container.service

# Setup zram
echo -e '[zram0]\nzram-size = min(ram / 2, 8192)\ncompression-algorithm = zstd\nswap-priority = 100' > /usr/lib/systemd/zram-generator.conf

# Tell Bazaar where to look for config (in the worst posible way)
sed -i 's|Exec=bazaar %U|Exec=bazaar --extra-blocklist /usr/share/spacefin/bazaar/blocklist.txt --extra-curated-config /usr/share/spacefin/bazaar/curated.yaml %U|' /usr/share/applications/io.github.kolunmi.Bazaar.desktop

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
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"Gandalf\"|
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

ln -sf /usr/lib/os-release /etc/os-release

# Patch bootc to not need sudo for updating
cat << 'EOF' > /etc/profile.d/bootc.sh
if [ "$EUID" -ne 0 ]; then
    bootc() {
        # Check if the command is already running with sudo
        if [ "$EUID" -eq 0 ]; then
            /usr/bin/bootc "$@"
        else
          if [ "$1" = "update" ] || [ "$1" = "upgrade" ] || [ "$1" = "status" ]; then
            sudo /usr/bin/bootc "$@"
          else
            /usr/bin/bootc "$@"
          fi
        fi
    }
fi
EOF

cat << 'EOF' > /etc/sudoers.d/001-bootc
%wheel ALL=(ALL) NOPASSWD: /usr/bin/bootc update, /usr/bin/bootc upgrade, /usr/bin/bootc status, /usr/bin/bootc status --booted
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
pacman -Rns --noconfirm  base-devel paru
pacman -Scc --noconfirm
find /etc/fonts/conf.d/ -xtype l -delete
fc-cache -fv

# Remove nano (swaped with micro) and sudo (swaped with run0)
pacman -R --noconfirm nano sudo
rm /usr/bin/su

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
