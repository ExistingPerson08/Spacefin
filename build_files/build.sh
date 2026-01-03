#!/bin/bash

set -ouex pipefail
pacman -Syu --noconfirm

# Install de specific packages
case "$1" in
    "cosmic")
        DE_NAME="main"
        # Install Cosmic
        pacman -S --noconfirm cosmic-session cosmic-greeter

        systemctl enable cosmic-greeter
        ;;
    "gnome")
        DE_NAME="gnome"

        # Setup GNOME
        pacman -S --noconfirm gnome-shell gnome-session gdm nautilus

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
        pacman -S --noconfirm niri-git dms-shell-git mate-polkit wl-clipboard dgop gdm

        # Install aditional packages and dependencies
        pacman -S --noconfirm \
            nm-connection-editor \
            adw-gtk-theme \
            nautilus \
            nautilus-share \
            nautilus-python \
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

        systemctl enable --global dms
        systemctl enable gdm
        ;;
    "kde")
        DE_NAME="kde"

        # Setup kde
        pacman -S --noconfirm \
            qt \
            krdp \
            kdeconnectd \
            kdeplasma-addons \
            kio-extras \
            gwenview \
            breeze-gtk-gtk3 \
            breeze-gtk-gtk4 \
            ksystemlog \
            kde-desktop \
            dolphin \
            krunner-bazaar

        pacman -R --noconfirm \
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
        pacman -S --noconfirm \
            steam \
            lutris

        pacman -S --noconfirm \
            mangohud \
            vesktop \
            wine \
            gamescope \
            vkBasalt \
            winetricks

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
pacman -S --noconfirm system76-scheduler
systemctl enable com.system76.Scheduler

# Install additional packages
pacman -S --noconfirm \
    fastfetch \
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
    tealdeer \
    thefuck \
    starship \
    quickemu \
    waydroid \
    tailscale \
    restic \
    rclone \
    git \
    python-pip \
    python-requests \
    fprintd \
    borg \
    tuned \
    tuned-ppd

systemctl enable tailscaled.service
systemctl enable ufw

# Temporary: Steam and dykscord on all images
pacman -S --noconfirm \
    steam \
    vesktop \
    discord

pacman -S --noconfirm gnome-backgrounds

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

# Cleanup
rm -rf \
    /tmp/* \
    /var/cache/pacman/pkg/*

# Finalize
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name lib \! -name rpm-ostree -exec rm -fr {} \;
mkdir -p /var/tmp
chmod -R 1777 /var/tmp
