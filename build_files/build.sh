#!/bin/bash

set -ouex pipefail

case "$1" in
    "main")
        # Using tagged Cosmic desktop in main image
        dnf install -y @cosmic-desktop @cosmic-desktop-apps --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator
        
        # Remove GNOME desktop and duplicated apps
        dnf5 -y group remove gnome-desktop
        dnf -y remove gdm gnome-shell gnome-session
        dnf -y remove gnome-tweaks nautilus

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
        ;;
    "exp")
        # Using latest (nightly) Cosmic desktop in exp image
        dnf copr enable -y ryanabx/cosmic-epoch
        dnf install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

        # Cleanup
        dnf copr remove -y ryanabx/cosmic-epoch

        # Remove unused Bluefin-dx apps
        dnf remove -y sysprof

        # Remove incompatible just recipes
        for recipe in "devmode" "toggle-devmode" "install-system-flatpaks" ; do
          if ! grep -l "^$recipe:" /usr/share/ublue-os/just/*.just | grep -q .; then
            echo "Skipping"
          fi
          sed -i "s/^$recipe:/_$recipe:/" /usr/share/ublue-os/just/*.just
        done
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

# Install additional GNOME apps
# (native version is better than flatpak)
dnf install -y showtime gnome-firmware

# Use ghostty instead of ptyxis
dnf copr enable -y scottames/ghostty
dnf install -y ghostty
dnf remove -y ptyxis

# Remove Bazaar due old version
dnf remove -y bazaar

# Cleanup
dnf copr remove -y scottames/ghostty
dnf clean all -y
