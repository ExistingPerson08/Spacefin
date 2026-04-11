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
            xdg-desktop-portal-cosmic \
            gvfs \
            gvfs-mtp \
            gvfs-smb \
            gvfs-wsdd

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
          gnome-shell-extension-dash-to-dock \
          gnome-shell-extension-dash-to-panel \
          gnome-shell-extension-arc-menu \
          gnome-shell-extension-appindicator \
          gnome-shell-extension-gsconnect \
          gnome-shell-extension-compiz-windows-effect-git \
          gnome-shell-extension-blur-my-shell \
          gnome-shell-extension-caffeine \
          gnome-shell-extension-pop-shell-git \
          ulauncher \
          gnome-online-accounts \
          gvfs \
          gvfs-goa \
          gvfs-onedrive \
          gvfs-mtp \
          gvfs-smb \
          gvfs-wsdd \
          gnome-text-editor

        install_aur gnome-shell-extension-just-perfection-desktop
        install_aur gnome-shell-extension-gtk4-desktop-icons-ng

        build_spacefin_package Spacefin-warehouse/main/stillcontrol

        # Fix just perfection gschemas
        ln -s /usr/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml /usr/share/glib-2.0/schemas/

        # Fix dash to panel missing gschemas
        DASH_TO_PANEL_SCHEMA="/usr/share/glib-2.0/schemas/org.gnome.shell.extensions.dash-to-panel.gschema.xml"
        sed -i 's|<\/schema>|    <key type="as" name="available-monitors">\n      <default>[]<\/default>\n      <summary>Patch for still-control<\/summary>\n    <\/key>\n<\/schema>|' "$DASH_TO_PANEL_SCHEMA"

        glib-compile-schemas /usr/share/glib-2.0/schemas/

        # Remove build-in extension app
        rm /usr/share/applications/org.gnome.Extensions.desktop

        systemctl enable gdm
        ;;
    "niri")
        DE_NAME="niri"

        # Install and setup niri
        pacman -S --noconfirm niri dms-shell-git mate-polkit wl-clipboard dgop matugen

        # Install aditional packages and dependencies
        pacman -S --noconfirm \
            nm-connection-editor \
            nautilus \
            nautilus-share \
            nautilus-python \
            nautilus-open-any-terminal \
            gvfs \
            gvfs-mtp \
            gvfs-smb \
            gvfs-wsdd \
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
        install_aur greetd-dms-greeter-git

        # Setup dms greeter
        printf '[terminal]\nvt = 1\n\n[default_session]\nuser = "greeter"\ncommand = "/usr/bin/dms-greeter --command niri"\n' | sudo tee /etc/greetd/config.toml

        systemctl enable --global dms dsearch
        systemctl enable greetd
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
    podman \
    podman-docker \
    flatpak-builder \
    quickemu \
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
    micro \
    nss-mdns \
    samba \
    borg

pacman -S --noconfirm gnome-backgrounds archlinux-wallpaper

# UFW config
ufw allow CIFS

# Remove nano (swaped with micro)
pacman -R --noconfirm nano

# Build spacefin packages
build_spacefin_package ExistingRules/main
build_spacefin_package Spacefin-cli/main

# Gaming stack: steam, vesktop & OGC gamescope-session
pacman -S --noconfirm \
    steam \
    vesktop \
    waydroid \
    cachyos-v3/gamescope \
    chaotic-aur/faugus-launcher \
    chaotic-aur/gamescope-session-git \
    #chaotic-aur/icoextract

git clone https://github.com/OpenGamingCollective/gamescope-session-steam/
cp -rv gamescope-session-steam/usr/* /usr/ && rm -rfv gamescope-session-steam/
rm /usr/share/wayland-sessions/gamescope-session.desktop

# Systemd services
systemctl enable ufw
systemctl disable tailscaled.service
systemctl disable waydroid-container.service

# Setup zram
echo -e '[zram0]\nzram-size = min(ram / 2, 8192)\ncompression-algorithm = zstd\nswap-priority = 100' > /usr/lib/systemd/zram-generator.conf

# Tell Bazaar where to look for config (in the worst posible way)
sed -i 's|Exec=bazaar %U|Exec=bazaar --extra-blocklist /usr/share/spacefin/bazaar/blocklist.yaml --extra-curated-config /usr/share/spacefin/bazaar/curated.yaml %U|' /usr/share/applications/io.github.kolunmi.Bazaar.desktop

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

# For some reason, uninstalling base-devel also uninstalls sudo
pacman -S --noconfirm sudo

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
