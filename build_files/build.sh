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
    fwupd \
    fwupd-plugin-flashrom \
    fwupd-plugin-modem-manager \
    fwupd-plugin-uefi-capsule-data \

# Additional drivers
dnf5 install -y \
    NetworkManager-wifi \
    atheros-firmware \
    brcmfmac-firmware \
    iwlegacy-firmware \
    iwlwifi-dvm-firmware \
    iwlwifi-mvm-firmware \
    mt7xxx-firmware \
    nxpwireless-firmware \
    realtek-firmware \
    tiwilink-firmware \
    alsa-firmware \
    alsa-sof-firmware \
    alsa-tools-firmware \
    intel-audio-firmware \
    ublue-os-udev-rules

# Install de specific packages
case "$1" in
    "cosmic")
        DE_NAME="main"
        # Using latest (nightly) Cosmic desktop until stable release
        dnf5 copr enable -y ryanabx/cosmic-epoch
        dnf5 install -y cosmic-desktop --exclude=okular,rhythmbox,thunderbird,nheko,ark,gnome-calculator
        dnf5 copr remove -y ryanabx/cosmic-epoch

        systemctl enable cosmic-greeter
        ;;
    "gnome")
        DE_NAME="gnome"

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
          gnome-shell-extension-hotedge \
          gnome-shell-extension-caffeine \
          gnome-shell-extension-desktop-cube \
          gnome-shell-extension-just-perfection \
          steamdeck-gnome-presets \
          gnome-shell-extension-logo-menu \
          gnome-shell-extension-pop-shell \
          xprop \
          papers \
          loupe \
          decibels \
          gnome-text-editor \
          rom-properties-gtk3 \
          --exclude=gnome-extensions-app
        ;;
    "niri")
        DE_NAME="niri"

        # Install and setup niri
        dnf5 copr enable -y yalter/niri
        dnf5 install -y niri --setopt=install_weak_deps=False --exclude=alacritty
        dnf5 copr remove -y yalter/niri

        dnf5 copr enable -y avengemedia/dms
        dnf5 install -y dms mate-polkit wl-clipboard dms-greeter --setopt=install_weak_deps=True
        dnf5 copr remove -y avengemedia/dms

        # Install aditional packages and dependencies
        dnf5 install -y \
            nm-connection-editor \
            adw-gtk3-theme \
            nautilus \
            papers \
            decibels \
            shotwell \
            waybar \
            wl-mirror \
            swaybg \
            swaylock \
            swayidle \
            mako \
            rofi \
            libnotify \
            gnome-keyring \
            xdg-desktop-portal-gtk \
            xdg-desktop-portal-gnome \
            xwayland-satellite \

        echo "import \"/usr/share/spacefin/just/niri.just\"" >>/usr/share/ublue-os/justfile

        systemctl enable --global dms
        systemctl enable --global dsearch
        systemctl enable greetd
        ;;
    "miracle-wm")
        DE_NAME="miracle-wm"

        # Install and setup miracle-wm
        dnf5 install miracle-wm

        dnf5 copr enable -y avengemedia/dms
        dnf5 install -y dms-greeter
        dnf5 copr remove -y avengemedia/dms

        # Install aditional packages and dependencies
        dnf5 install -y \
            nm-connection-editor \
            blueman \
            adw-gtk3-theme \
            nautilus \
            papers \
            decibels \
            shotwell \
            waybar \
            wl-mirror \
            swaybg \
            swaylock \
            swayidle \
            mako \
            rofi \
            libnotify \
            gnome-keyring \
            mate-polkit \
            wl-clipboard

        systemctl enable greetd
        ;;
    "budgie")
        DE_NAME="budgie"

        # Install and setup Budgie
        dnf5 install -y budgie-desktop budgie-session budgie-backgrounds budgie-control-center

        dnf5 install -y budgie-extras
        ;;
    "kde")
        DE_NAME="kde"

        # Setup kde
        dnf5 -y install \
            qt \
            krdp \
            steamdeck-kde-presets-desktop \
            kdeconnectd \
            kdeplasma-addons \
            rom-properties-kf6 \
            fcitx5-mozc \
            fcitx5-chinese-addons \
            fcitx5-hangul \
            kcm-fcitx5 \
            kio-extras \
            gwenview \
            breeze-gtk-gtk3 \
            breeze-gtk-gtk4 \
            ksystemlog \
            krunner-bazaar

        dnf5 -y remove \
            plasma-welcome \
            plasma-welcome-fedora \
            plasma-discover-kns \
            kcharselect \
            kde-partitionmanager \
            akonadi-server \
            akonadi-server-mysql \
            mariadb \
            mariadb-backup \
            mariadb-common \
            mariadb-cracklib-password-check \
            mariadb-errmsg \
            mariadb-gssapi-server \
            mariadb-server \
            konsole

        # Install additional packages
        dnf5 -y --setopt=install_weak_deps=False install \
            steam \
            lutris

        dnf5 install -y \
            mangohud \
            wine \
            waydroid \
            gamescope \
            vkBasalt \
            winetricks \
            plasma-wallpapers-dynamic

        # Hide Discover entries by renaming them (allows for easy re-enabling)
        discover_apps=(
          "org.kde.discover.desktop"
          "org.kde.discover.flatpak.desktop"
          "org.kde.discover.notifier.desktop"
          "org.kde.discover.urlhandler.desktop"
        )

        for app in "${discover_apps[@]}"; do
          if [ -f "/usr/share/applications/${app}" ]; then
            mv "/usr/share/applications/${app}" "/usr/share/applications/${app}.disabled"
          fi
        done

        # Disable Discover update notifications
        rm /etc/xdg/autostart/org.kde.discover.notifier.desktop

        # Set Bazaar as default appstore
        echo "application/vnd.flatpak.ref=io.github.kolunmi.Bazaar.desktop" >> /usr/share/applications/mimeapps.list

        # Pin apps to taskbar
        sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:steam.desktop,applications:net.lutris.Lutris.desktop,applications:com.mitchellh.ghostty.desktop,applications:io.github.kolunmi.Bazaar.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml
        ;;
esac

# Install edition specific packages
case "$2" in
    "main")
        # Skipping
        IMAGE_NAME="$DE_NAME"
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
    dbus-x11 \
    fish \
    zsh \
    bluefin-cli-logos \
    duperemove \
    ddcutil \
    uupd \
    gnome-disk-utility \
    java-latest-openjdk-devel \
    bazaar \
    docker \
    docker-compose \
    flatpak-builder \
    quickemu \
    waydroid \
    webapp-manager \
    restic \
    rclone \
    git \
    python3-pip \
    python3-requests \
    fprintd \
    fprintd-pam \
    tuned \
    tuned-ppd

dnf5 install -y --enable-repo=copr:copr.fedorainfracloud.org:ublue-os:packages ublue-os-media-automount-udev
dnf5 install -y --skip-broken steamdeck-backgrounds gnome-backgrounds

# Setup automatic-updates
sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service
systemctl enable uupd

# Setup internal drives automount
git clone --depth=1 https://github.com/Zeglius/media-automount-generator
cd ./media-automount-generator
./install.sh
cd ../
rm -rf ./media-automount-generator

# Add Flatpak preinstall
dnf5 -y copr enable ublue-os/flatpak-test
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
dnf5 -y copr disable ublue-os/flatpak-test

# Use ghostty instead of ptyxis
dnf5 install -y ghostty
dnf5 remove -y ptyxis

# Setup systemd services
systemctl enable brew-setup.service
systemctl disable brew-upgrade.timer
systemctl disable brew-update.timer

# Write image info
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_VENDOR="existingperson08"
image_flavor="main"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"
HOME_URL="https://github.com/ExistingPerson08/Spacefin"

cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$image_flavor",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag":"latest",
  "base-image-name": "fedora",
  "fedora-version": "43"
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

# Add Flathub
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove Fedora Flatpaks
rm -rf /usr/lib/systemd/system/flatpak-add-fedora-repos.service

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
