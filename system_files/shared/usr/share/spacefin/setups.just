enable-cosmic-repo:
    echo "Adding COSMIC repo"
    flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
    echo "Adding Flathub user (needed for COSMIC repo to work)"
    flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

setup-modding:
    echo ""
    echo "Installing r2modman"
    echo ""
    TEMP_FILE="/tmp/r2modman.flatpak"
    curl -L "https://github.com/ebkr/r2modmanPlus/releases/download/v3.2.15/r2modman-3.2.15-x86_64.flatpak" -o "$TEMP_FILE"
    run0 flatpak install -y --system "$TEMP_FILE"
    rm "$TEMP_FILE"
    echo ""
    echo "Installing Curseforge app"
    echo ""
    TEMP_FILE="/tmp/curseforge.AppImage"
    flatpak install -y --system flathub it.mijorus.gearlever
    curl -L "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage" -o "$TEMP_FILE"
    flatpak run it.mijorus.gearlever --integrate "$TEMP_FILE" -y --replace
    echo ""
    echo "Installing Proton tools"
    echo ""
    flatpak install -y --system flathub net.davidotek.pupgui2
    flatpak install -y --system flathub com.github.Matoking.protontricks
    echo ""
    echo "Modding setup finished!"

setup-dev:
    brew tap ublue-os/tap
    brew install --cask vscodium-linux
    brew install lazygit uv
    flatpak install --system --flathub dev.zed.Zed -y
    echo ""
    echo "Developer setup finished!"

setup-blink:
    brew install trash-cli atuin ranger scrcpy cowsay cmatrix commitizen tealdeer

setup-touchscreen:
    rm -f ~/.config/niri/touchscreen.kdl
    cp /usr/share/spacefin/configs/touchscreen.kdl ~/.config/niri/

install-plex:
    /usr/share/spacefin/scripts/plex-install.sh

remove-plex:
    /usr/share/spacefin/scripts/plex-remove.sh

install-system-flatpaks:
    flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    xargs -a /usr/share/spacefin/flatpaks.list flatpak install --system -y

install-recommended-flatpaks:
    #!/bin/bash
    GEFORCE_URL="https://international.download.nvidia.com/GFNLinux/GeForceNOWSetup.bin"
    GEFORCE_BIN="/tmp/GeForceNOWSetup.bin"

    flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    xargs -a /usr/share/spacefin/flatpaks-recommended.list flatpak install --system -y

    curl -L "$GEFORCE_URL" -o "$GEFORCE_BIN"
    chmod +x "$GEFORCE_BIN"
    "$GEFORCE_BIN"
