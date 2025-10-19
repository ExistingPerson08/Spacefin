#!/bin/bash

set -ouex pipefail

dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 install -y terra-release-extras
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable bazzite-org/bazzite
dnf5 -y copr enable bazzite-org/bazzite-multilib
dnf5 -y copr enable bazzite-org/rom-properties

case "$1" in
    "main")
        IMAGE_NAME="main"

        # Using tagged Cosmic desktop in main image
        dnf5 install -y @cosmic-desktop @cosmic-desktop-apps --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

        dnf5 copr enable -y kylegospo/system76-scheduler
        dnf5 install -y system76-scheduler

        systemctl enable cosmic-greeter
        systemctl enable com.system76.Scheduler

        # Cleanup
        dnf5 copr remove -y kylegospo/system76-scheduler
        ;;
    "hybrid")
        IMAGE_NAME="hybrid"

        # Using tagged Cosmic  desktop in hybrid image
        dnf5 install -y @cosmic-desktop @cosmic-desktop-apps --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

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
          rom-properties-gtk3 \
          --exclude=gnome-extensions-app
        ;;
    "exp")
        IMAGE_NAME="experimental"
        # Using latest (nightly) Cosmic desktop in exp image
        dnf5 copr enable -y ryanabx/cosmic-epoch
        dnf5 install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator

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
          rom-properties-gtk3 \
          --exclude=gnome-extensions-app

        # Install apps for experimental image
        dnf5 install -y \
            youtube-music \
            zed \
            codium \
            codium-marketplace \
            flatpak-builder \
            gnome-boxes \
            zsh \
            restic \
            rclone \
            waydroid \
            scrcpy \
            quickemu

        # Add Waydroid just command
        echo "import \"/usr/share/spacefin/just/waydroid.just\"" >>/usr/share/ublue-os/justfile

        # Cleanup
        dnf5 copr remove -y ryanabx/cosmic-epoch
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

# Setup firmware
firmware="linux-firmware-whence qcom-wwan-firmware linux-firmware amd-gpu-firmware amd-ucode-firmware atheros-firmware brcmfmac-firmware cirrus-audio-firmware intel-audio-firmware intel-gpu-firmware intel-vsc-firmware iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware libertas-firmware mt7xxx-firmware nvidia-gpu-firmware nxpwireless-firmware realtek-firmware tiwilink-firmware"
dnf5 -y remove --no-autoremove $firmware
dnf5 -y install --repo="copr:copr.fedorainfracloud.org:bazzite-org:bazzite" $firmware

git clone https://github.com/hhd-dev/hwfirm /tmp/hwfirm --depth 1
cp -r /tmp/hwfirm/cirrus/* /usr/lib/firmware/cirrus/
cp -r /tmp/hwfirm/rtl_bt/* /usr/lib/firmware/rtl_bt/
cp -r /tmp/hwfirm/awinic/* /usr/lib/firmware/
cp -r /tmp/hwfirm/tas/*    /usr/lib/firmware/
rm -rf /tmp/hwfirm/

rm /usr/lib/firmware/rtl_bt/rtl8822cu_config.bin.xz

# Remove incompatible just recipes
for recipe in "devmode" "toggle-devmode" "install-system-flatpaks" "update" ; do
  if ! grep -l "^$recipe:" /usr/share/ublue-os/just/*.just | grep -q .; then
    echo "Skipping"
  fi
  sed -i "s/^$recipe:/_$recipe:/" /usr/share/ublue-os/just/*.just
done

# Add to justfile
echo "import \"/usr/share/spacefin/just/spacefin.just\"" >>/usr/share/ublue-os/justfile

# Install additional packages
dnf5 install -y fastfetch ublue-brew ublue-motd firewall-config fish bluefin-cli-logos showtime gnome-firmware duperemove
dnf5 install -y --enable-repo=copr:copr.fedorainfracloud.org:ublue-os:packages ublue-os-media-automount-udev
dnf5 install -y steamdeck-backgrounds gnome-backgrounds

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
systemctl disable waydroid-container.service

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

# Cleanup
for repo in terra terra-extras; do
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/$repo.repo
done
dnf5 -y copr remove bazzite-org/rom-properties
dnf5 -y copr remove ublue-os/packages
dnf5 -y copr remove ublue-os/staging
dnf5 -y copr remove bazzite-org/bazzite
dnf5 -y copr remove bazzite-org/bazzite-multilib
dnf5 remove -y htop nvtop firefox firefox-langpacks toolbox clapper fedora-bookmarks fedora-chromium-config fedora-chromium-config-gnome
dnf5 clean all -y

# Finalize
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;
mkdir -p /var/tmp
chmod -R 1777 /var/tmp
