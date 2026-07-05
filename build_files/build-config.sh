#!/bin/bash

set -ouex pipefail
IMAGE_NAME="desktop"

# UFW config
ufw default deny
ufw allow CIFS
ufw allow 9300

# Auto-enable bluetooth
sed -i 's/^[;#]*\s*AutoEnable\s*=\s*.*/AutoEnable=true/' /etc/bluetooth/main.conf

# Change user lock after wrong password
sed -i 's/^[#]*\s*deny\s*=\s*.*/deny = 5/' /etc/security/faillock.conf

# Setup zram
echo -e '[zram0]\nzram-size = min(ram / 2, 8192)\ncompression-algorithm = zstd\nswap-priority = 100' > /usr/lib/systemd/zram-generator.conf

# Add flathub to image
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Write image info
IMAGE_INFO="/usr/share/spacefin/image-info.json"
IMAGE_VENDOR="existingperson08"
image_flavor="main"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"
HOME_URL="https://github.com/ExistingPerson08/Spacefin"

mkdir /usr/share/spacefin/
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
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:existingperson08:spacefin\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"https://existingperson08.github.io/spacefin-docs/\"|
EOF

echo 'VERSION_CODENAME="The Dark One"' >> /usr/lib/os-release
echo 'DEFAULT_HOSTNAME="Spacefin"' >> /usr/lib/os-release

ln -sf /usr/lib/os-release /etc/os-release

# Workaround to make nix and snaps work
# They are not installed by default
mkdir /nix
mkdir /snap

systemd-sysusers --root=/
systemd-tmpfiles --root=/ --create --prefix=/var/lib/polkit-1
