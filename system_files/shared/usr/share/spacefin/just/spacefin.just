enable-cosmic-repo:
  echo "Adding COSMIC repo"
  flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
  echo "Adding Flathub user (needed for COSMIC repo to work)"
  flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

update:
  update

install-nix:
    #!/usr/bin/env bash
    set -euo pipefail

    NIX_DAEMON_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    NIX_INSTALLER="https://install.determinate.systems/nix"

    echo "Setting up Nix package manager..."
    curl --proto '=https' --tlsv1.2 -sSf -L "$NIX_INSTALLER" | sh -s -- install --no-confirm
    [ -f "$NIX_DAEMON_SCRIPT" ] && . "$NIX_DAEMON_SCRIPT"
    echo "Nix package manager installed."

install-snap:
    sudo rpm-ostree install snapd
    echo "Snapd installed. Reboot to use snap!"

fix-bazaar-config:
    flatpak override --user io.github.kolunmi.Bazaar --filesystem=host-etc
