#!/bin/bash

set -ouex pipefail
pacman -Syu --noconfirm
pacman-key --init
pacman-key --populate archlinux

# Speed up downloads and fix install errors
sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
sed -i 's/^Architecture = auto/Architecture = auto x86_64_v4/' /etc/pacman.conf

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

# Add repos
pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key F3B607488DB35A47
pacman -U --noconfirm 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-22-1-any.pkg.tar.zst' \
'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-22-1-any.pkg.tar.zst' \
'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-22-1-any.pkg.tar.zst'
sed -i '/^\[core\]/i \[cachyos-znver4\]\nInclude = \/etc\/pacman.d\/cachyos-v4-mirrorlist\n\n\[cachyos-core-znver4\]\nInclude = \/etc\/pacman.d\/cachyos-v4-mirrorlist\n\n\[cachyos-extra-znver4\]\nInclude = \/etc\/pacman.d\/cachyos-v4-mirrorlist\n\n' /etc/pacman.conf

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
pacman-key --init && \
pacman-key --lsign-key 3056513887B78AEB && \
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm && \
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm && \
echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf && \
echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \

pacman -Syy

# Base system
pacman -S --noconfirm base dracut linux-zen linux-firmware ostree btrfs-progs e2fsprogs xfsprogs dosfstools skopeo dbus dbus-glib glib2 ostree shadow && pacman -S --clean --noconfirm

pacman -S --noconfirm \
    reflector sudo bash fastfetch nano openssh unzip tar flatpak fuse2 fzf just wl-clipboard \
    libmtp nss-mdns samba smbclient networkmanager udiskie udisks2 udisks2-btrfs lvm2 cups cups-browsed cups-pdf system-config-printer hplip wireguard-tools \
    dosfstools cryptsetup bluez bluez-utils tuned tuned-ppd distrobox podman squashfs-tools zstd \
    ffmpeg ffmpegthumbnailer libcamera libcamera-tools libheif \
    amd-ucode intel-ucode efibootmgr shim mesa libva-intel-driver libva-mesa-driver \
    vpl-gpu-rt vulkan-icd-loader vulkan-intel vulkan-radeon apparmor xf86-video-amdgpu zram-generator \
    lm_sensors intel-media-driver git bootc openal ttf-twemoji curl

# Prepare build enviroment
pacman -S --needed --noconfirm core/base-devel extra/git chaotic-aur/paru
useradd -m build 2>/dev/null
echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir -p ./build_tmp
chown build:build ./build_tmp

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

# Fix users and group after rebasing from non-arch image
mkdir -p /usr/lib/systemd/system-preset /usr/lib/systemd/system
echo -e '#!/bin/sh\n\
cat /usr/lib/sysusers.d/*.conf | \
grep -e "^g" | \
grep -v -e "^#" | \
awk "NF" | \
awk '\''{print $2}'\'' | \
grep -v -e "wheel" -e "root" -e "sudo" | \
xargs -I{} sed -i "/{}/d" "$1"' > /usr/libexec/arch-group-fix
chmod +x /usr/libexec/arch-group-fix

echo -e '[Unit]\n\
Description=Fix groups\n\
DefaultDependencies=no\n\
After=local-fs.target\n\
Before=sysinit.target systemd-resolved.service\n\
Wants=local-fs.target\n\
\n\
[Service]\n\
Type=oneshot\n\
ExecStart=/usr/libexec/arch-group-fix /etc/group\n\
ExecStart=/usr/libexec/arch-group-fix /etc/gshadow\n\
ExecStart=/usr/bin/systemd-sysusers\n\
\n\
[Install]\n\
WantedBy=sysinit.target' > /usr/lib/systemd/system/arch-group-fix.service

echo -e "enable arch-group-fix.service" > /usr/lib/systemd/system-preset/01-arch-group-fix.preset

# Sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers || \
    echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo -e 'enable systemd-resolved.service' > /usr/lib/systemd/system-preset/91-resolved-default.preset
echo -e 'L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf' > /usr/lib/tmpfiles.d/resolved-default.conf
systemctl preset systemd-resolved.service

systemctl enable polkit.service
systemctl enable arch-group-fix.service
systemctl enable NetworkManager.service
systemctl enable cups.socket
systemctl enable cups-browsed.service
systemctl enable tuned-ppd.service
systemctl enable tuned.service
systemctl enable systemd-resolved.service
systemctl enable systemd-resolved-varlink.socket
systemctl enable systemd-resolved-monitor.socket
systemctl enable bluetooth.service
systemctl enable avahi-daemon.service
systemctl enable ufw
systemctl disable tailscaled.service
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
