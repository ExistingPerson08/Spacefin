#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable bazzite-org/bazzite
dnf5 -y copr enable bazzite-org/bazzite-multilib
dnf5 -y copr enable bazzite-org/rom-properties
dnf5 -y copr enable kylegospo/system76-scheduler

IMAGE_NAME="gx"

# Install gx packages
dnf5 install -y --disableexcludes \
    waydroid \
    wine \
    winetricks \
    mangohud

dnf5 install -y https://downloads.plex.tv/plex-media-server-new/1.42.2.10156-f737b826c/redhat/plexmediaserver-1.42.2.10156-f737b826c.x86_64.rpm

dnf5 -y --setopt=install_weak_deps=False install \
    steam \
    lutris

# Add Waydroid just command
echo "import \"/usr/share/spacefin/just/waydroid.just\"" >>/usr/share/ublue-os/justfile

systemctl disable waydroid-container.service

# Write image info
rm /usr/share/ublue-os/image-info.json
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
dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release terra-release terra-release-extras
dnf5 -y copr remove kylegospo/system76-scheduler
dnf5 -y copr remove bazzite-org/rom-properties
dnf5 -y copr remove ublue-os/packages
dnf5 -y copr remove ublue-os/staging
dnf5 -y copr remove bazzite-org/bazzite
dnf5 -y copr remove bazzite-org/bazzite-multilib
dnf5 clean all -y

# Finalize
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;
mkdir -p /var/tmp
chmod -R 1777 /var/tmp
