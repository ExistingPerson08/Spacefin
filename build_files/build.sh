#!/bin/bash

set -ouex pipefail

dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

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

        # Install GNOME extensions
        dnf5 -y install nautilus-gsconnect gnome-shell-extension-appindicator gnome-shell-extension-user-theme gnome-shell-extension-gsconnect gnome-shell-extension-compiz-windows-effect gnome-shell-extension-blur-my-shell gnome-shell-extension-hanabi gnome-shell-extension-hotedge gnome-shell-extension-caffeine gnome-shell-extension-desktop-cube
        ;;
    "exp")
        # Using latest (nightly) Cosmic desktop in exp image
        dnf copr enable -y ryanabx/cosmic-epoch
        dnf install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

        # Add niri
        dnf copr enable -y yalter/niri 
        dnf install -y niri

        # Install GNOME extensions
        dnf5 -y install nautilus-gsconnect gnome-shell-extension-appindicator gnome-shell-extension-user-theme gnome-shell-extension-gsconnect gnome-shell-extension-compiz-windows-effect gnome-shell-extension-blur-my-shell gnome-shell-extension-hanabi gnome-shell-extension-hotedge gnome-shell-extension-caffeine gnome-shell-extension-desktop-cube

        # Install apps for experimental image
        dnf install -y youtube-music zed codium codium-marketplace
        dnf install -y steam gamescope-session-steam

        # Cleanup
        dnf copr remove -y yalter/niri 
        dnf copr remove -y ryanabx/cosmic-epoch
        dnf remove -y sysprof
        ;;
esac

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
dnf install -y fastfetch 

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

# Cleanup
rm /etc/yum.repos.d/terra.repo
dnf remove -y htop nvtop gnome-tweaks firefox gnome-software gnome-software-rpm-plugin
dnf clean all -y
