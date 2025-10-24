#!/bin/bash
set -ouex pipefail

# Cleanup
for repo in terra terra-extras rpmfusion-free rpmfusion-nonfree; do
    rm /etc/yum.repos.d/$repo.repo
done
dnf5 -y copr remove kylegospo/system76-scheduler
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
