#!/bin/bash

set -ouex pipefail

dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 install -y terra-release-extras
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable bazzite-org/bazzite
dnf5 -y copr enable bazzite-org/bazzite-multilib
dnf5 -y copr enable bazzite-org/webapp-manager
dnf5 -y copr enable bazzite-org/rom-properties
dnf5 -y copr enable kylegospo/system76-scheduler

# Clean base
dnf5 remove -y htop nvtop firefox firefox-langpacks toolbox clapper fedora-bookmarks fedora-chromium-config fedora-chromium-config-gnome

# Swap patched packages
declare -A toswap=(
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite"]="wireplumber"
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite-multilib"]="xorg-x11-server-Xwayland"
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
    fwupd-plugin-uefi-capsule-data \

# Install edition specific packages
case "$1" in
    "main")
        IMAGE_NAME="main"
        # Using latest (nightly) Cosmic desktop until stable release
        dnf5 remove -y @cosmic-desktop @cosmic-desktop-apps --exclude=gnome-disk-utility,flatpak
        dnf5 copr enable -y ryanabx/cosmic-epoch
        dnf5 install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator
        dnf5 copr remove -y ryanabx/cosmic-epoch

        systemctl enable cosmic-greeter

        # Install additional packages
        dnf5 install -y \
            youtube-music \
            zed \
            codium \
            codium-marketplace \
            gnome-boxes \
            scrcpy \
            torbrowser-launcher \
            chromium \
            prismlauncher \
            quickemu

        dnf5 install -y https://github.com/TriliumNext/Trilium/releases/download/v0.99.3/TriliumNotes-v0.99.3-linux-x64.rpm
        ;;
    "gnome")
        IMAGE_NAME="gnome"

        # Setup GNOME
        dnf5 remove -y \
            gnome-classic-session \
            gnome-tour \
            gnome-extensions-app \
            gnome-system-monitor \
            gnome-software \
            gnome-software-rpm-ostree \
            gnome-tweaks \
            gnome-shell-extension-apps-menu \
            gnome-shell-extension-background-logo \
            yelp \
            gnome-initial-setup
        dnf5 -y install \
          nautilus-gsconnect \
          gnome-shell-extension-appindicator \
          gnome-shell-extension-user-theme \
          ulauncher \
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
          gnome-shell-extension-pop-shell \
          xprop \
          rom-properties-gtk3 \
          --exclude=gnome-extensions-app

        # Install additional packages
        dnf5 install -y \
            youtube-music \
            xournal \
            firefox \
            scrcpy \
            gnome-boxes \
            torbrowser-launcher
        ;;
    "cinnamon")
        IMAGE_NAME="cinnamon"
        dnf5 group install -y cinnamon-desktop
        dnf5 install -y lightdm

        systemctl enable lightdm

        # Workaround: fix dependencies conflicts
        dnf5 versionlock delete \
            mesa-dri-drivers \
            mesa-filesystem \
            mesa-libEGL \
            mesa-libGL \
            mesa-libgbm \
            mesa-va-drivers \
            mesa-vulkan-drivers

        # Install additional packages
        dnf5 -y --setopt=install_weak_deps=False install \
            steam \
            lutris

        dnf5 install -y \
            mangohud \
            webapp-manager \
            wine \
            thunderbird \
            gamescope \
            vkBasalt \
            qbittorrent \
            winetricks
        ;;
esac

# Enable system76-schenduler
dnf5 install -y system76-scheduler
systemctl enable com.system76.Scheduler

# Remove incompatible just recipes
for recipe in "devmode" "toggle-devmode" "install-system-flatpaks" "update" ; do
  if ! grep -l "^$recipe:" /usr/share/ublue-os/just/*.just | grep -q .; then
    echo "Skipping"
  fi
  sed -i "s/^$recipe:/_$recipe:/" /usr/share/ublue-os/just/*.just
done

# Add to justfile
echo "import \"/usr/share/spacefin/just/spacefin.just\"" >>/usr/share/ublue-os/justfile
echo "import \"/usr/share/spacefin/just/waydroid.just\"" >>/usr/share/ublue-os/justfile


# Install additional packages
dnf5 install -y \
    fastfetch \
    ublue-brew \
    ublue-motd \
    firewall-config \
    fish \
    zsh \
    bluefin-cli-logos \
    showtime \
    shotwell \
    decibels \
    gnome-firmware \
    gimp \
    papers \
    duperemove \
    uupd \
    gnome-disk-utility \
    java-latest-openjdk-devel \
    docker \
    docker-compose \
    flatpak-builder \
    waydroid \
    restic \
    rclone

dnf5 install -y --enable-repo=copr:copr.fedorainfracloud.org:ublue-os:packages ublue-os-media-automount-udev
dnf5 install -y steamdeck-backgrounds gnome-backgrounds

# Setup automatic-updates
sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service
systemctl enable uupd.timer

# Use ghostty instead of ptyxis
dnf5 install -y ghostty
dnf5 remove -y ptyxis

# Remove Bazaar due old version
dnf5 remove -y bazaar

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

# Write image info
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_VENDOR="existingperson08"
image_flavor="main"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$image_flavor",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag":"latest",
  "base-image-name": "fedora",
  "fedora-version": "42"
}
EOF

# Workaround to make nix and snaps work
# They are not installed by default
mkdir /nix
mkdir /snap

# Cleanup
dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release terra-release terra-release-extras
dnf5 -y copr remove kylegospo/system76-scheduler
dnf5 -y copr remove bazzite-org/rom-properties
dnf5 -y copr remove ublue-os/packages
dnf5 -y copr remove ublue-os/staging
dnf5 -y copr remove bazzite-org/webapp-manager
dnf5 -y copr remove bazzite-org/bazzite
dnf5 -y copr remove bazzite-org/bazzite-multilib
dnf5 clean all -y

# Finalize
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;
mkdir -p /var/tmp
chmod -R 1777 /var/tmp
