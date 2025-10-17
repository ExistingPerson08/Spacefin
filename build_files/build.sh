#!/bin/bash

set -ouex pipefail

dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf install -y terra-release-extras
dnf copr enable -y ublue-os/packages
dnf copr enable -y ublue-os/staging
dnf copr enable -y bazzite-org/bazzite
dnf copr enable -y bazzite-org/bazzite-multilib

case "$1" in
    "main")
        # Using tagged Cosmic desktop in main image
        dnf install -y @cosmic-desktop @cosmic-desktop-apps --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

        dnf copr enable -y kylegospo/system76-scheduler
        dnf install -y system76-scheduler
        
        systemctl enable cosmic-greeter
        systemctl enable com.system76.Scheduler

        # Cleanup
        dnf copr remove -y kylegospo/system76-scheduler
        ;;
    "hybrid")
        # Using tagged Cosmic  desktop in hybrid image
        dnf install -y @cosmic-desktop @cosmic-desktop-apps --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

        # Setup GNOME
        dnf remove -y gnome-classic-session gnome-tour gnome-extensions-app gnome-system-monitor gnome-software gnome-software-rpm-plugin gnome-tweaks gnome-shell-extension-apps-menu gnome-shell-extension-background-logo
        dnf5 -y swap --repo terra-extras gnome-shell gnome-shell
        dnf5 versionlock add gnome-shell
        dnf5 -y install \
          nautilus-gsconnect \
          gnome-shell-extension-appindicator \
          gnome-shell-extension-user-theme \
          gnome-shell-extension-gsconnect \
          gnome-shell-extension-compiz-windows-effect \
          gnome-shell-extension-blur-my-shell \
          gnome-shell-extension-hanabi \
          gnome-shell-extension-hotedge \
          gnome-shell-extension-caffeine \
          gnome-shell-extension-desktop-cube \
          gnome-shell-extension-just-perfection \
          steamdeck-gnome-presets \
          gnome-shell-extension-logo-menu \
          --exclude=gnome-extensions-app
        ;;
    "exp")
        # Using latest (nightly) Cosmic desktop in exp image
        dnf copr enable -y ryanabx/cosmic-epoch
        dnf install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

        # Add niri
        dnf copr enable -y yalter/niri 
        dnf install -y niri

        # Setup GNOME
        dnf remove -y gnome-classic-session gnome-tour gnome-extensions-app gnome-system-monitor gnome-software gnome-software-rpm-plugin gnome-tweaks gnome-shell-extension-apps-menu gnome-shell-extension-background-logo
        dnf5 -y swap --repo terra-extras gnome-shell gnome-shell
        dnf5 versionlock add gnome-shell
        dnf5 -y install \
          nautilus-gsconnect \
          gnome-shell-extension-appindicator \
          gnome-shell-extension-user-theme \
          gnome-shell-extension-gsconnect \
          gnome-shell-extension-compiz-windows-effect \
          gnome-shell-extension-blur-my-shell \
          gnome-shell-extension-hanabi \
          gnome-shell-extension-hotedge \
          gnome-shell-extension-caffeine \
          gnome-shell-extension-desktop-cube \
          gnome-shell-extension-just-perfection \
          steamdeck-gnome-presets \
          gnome-shell-extension-logo-menu \
          --exclude=gnome-extensions-app

        # Install apps for experimental image
        dnf install -y youtube-music zed codium codium-marketplace
        dnf install -y qemu qemu-char-spice qemu-device-display-virtio-gpu qemu-device-display-virtio-vga qemu-device-usb-redirect qemu-img qemu-system-x86-core qemu-user-binfmt qemu-user-static
        dnf install -y flatpak-builder virt-manager virt-v2v virt-viewer
        dnf install -y steam gamescope-session-steam gamescope gamescope-session waydroid

        # Cleanup
        dnf copr remove -y yalter/niri 
        dnf copr remove -y ryanabx/cosmic-epoch
        ;;
esac

# Swap patched packages
declare -A toswap=(
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite"]="wireplumber"
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite-multilib"]="xorg-x11-server-Xwayland"
    ["terra-extras"]="switcheroo-control"
    ["terra-mesa"]="mesa-filesystem"
    ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd"
)

for repo in "${!toswap[@]}"; do
    for package in ${toswap[$repo]}; do
        dnf5 -y swap --repo="$repo" "$package" "$package"
    done
done

dnf5 versionlock add \
    wireplumber \
    wireplumber-libs \
    xorg-x11-server-Xwayland \
    switcheroo-control \
    mesa-dri-drivers \
    mesa-filesystem \
    mesa-libEGL \
    mesa-libGL \
    mesa-libgbm \
    mesa-va-drivers \
    mesa-vulkan-drivers \
    fwupd \
    fwupd-plugin-flashrom \
    fwupd-plugin-modem-manager \
    fwupd-plugin-uefi-capsule-data

# Remove incompatible just recipes
for recipe in "devmode" "toggle-devmode" "install-system-flatpaks" ; do
  if ! grep -l "^$recipe:" /usr/share/ublue-os/just/*.just | grep -q .; then
    echo "Skipping"
  fi
  sed -i "s/^$recipe:/_$recipe:/" /usr/share/ublue-os/just/*.just
done

# Add to justfile
echo "import \"/usr/share/spacefin/just/spacefin.just\"" >>/usr/share/ublue-os/justfile

# Install additional packages
dnf install -y fastfetch ublue-brew ublue-motd firewall-config fish bluefin-cli-logos ublue-polkit-rule
dnf5 install -y --enable-repo=copr:copr.fedorainfracloud.org:ublue-os:packages ublue-os-media-automount-udev

# Install additional GNOME apps
# (native version is better than flatpak)
dnf install -y showtime gnome-firmware

# Use ghostty instead of ptyxis
dnf install -y ghostty
dnf remove -y ptyxis

# Remove Bazaar due old version
dnf remove -y bazaar

# Add Flatpak preinstall
dnf5 -y copr enable ublue-os/flatpak-test
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
dnf5 -y copr disable ublue-os/flatpak-test

# Setup systemd services
systemctl enable brew-setup.service
systemctl disable brew-upgrade.timer
systemctl disable brew-update.timer
systemctl disable waydroid-container.service

# Cleanup
for repo in terra terra-extras; do
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/$repo.repo
done
dnf copr remove -y bazzite-org/bazzite
dnf copr remove -y bazzite-org/bazzite-multilib
dnf copr remove -y ublue-os/packages
dnf copr remove -y ublue-os/staging
dnf remove -y htop nvtop firefox firefox-langpacks toolbox
dnf clean all -y
