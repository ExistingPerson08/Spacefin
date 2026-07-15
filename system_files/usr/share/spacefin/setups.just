[group("setups")]
enable-cosmic-repo:
    echo "Adding COSMIC repo"
    flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
    echo "Adding Flathub user (needed for COSMIC repo to work)"
    flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

[group("setups")]
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

[group("setups")]
setup-dev:
    brew tap --trust ublue-os/tap
    brew install --cask vscodium-linux
    brew install lazygit uv gh
    echo ""
    echo "Developer setup finished!"

[group("setups")]
setup-blink:
    brew install trash-cli atuin ranger scrcpy cowsay cmatrix commitizen tealdeer

[group("setups")]
setup-touchscreen:
    rm -f ~/.config/niri/touchscreen.kdl
    cp /usr/share/spacefin/configs/touchscreen.kdl ~/.config/niri/

[group("setups")]
setup-workspace-rules:
    rm -f ~/.config/niri/workspaces.kdl
    cp /usr/share/spacefin/configs/workspaces.kdl ~/.config/niri/

[group("setups")]
setup-nix:
    #!/usr/bin/bash
    echo "Installing Nix"
    echo "Note: you'll need to enter your password multiple times"
    echo ""

    # Setup sudo needed for installation
    run0 bootc usroverlay
    run0 mv /usr/bin/sudo /usr/bin/sudo.backup
    run0 pacman -S --noconfirm sudo
    run0 sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers || \
    run0 echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

    # Install Nix
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install

    # Remove sudo
    run0 pacman -R --noconfirm sudo
    run0 mv /usr/bin/sudo.backup /usr/bin/sudo

    echo ""
    echo "Nix is installed!"
    echo "Reboot is recommended to apply all changes"

[group("setups")]
install-plex:
    /usr/share/spacefin/scripts/plex-install.sh

[group("setups")]
remove-plex:
    /usr/share/spacefin/scripts/plex-remove.sh

[group("steam")]
install-steamcmd:
    #!/usr/bin/bash
    echo "Installing SteamCMD..."
    echo ""
    mkdir -p ~/.steam
    curl -L https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -o /tmp/steamcmd.tar.gz
    tar -xvzf /tmp/steamcmd.tar.gz -C ~/.steam
    rm /tmp/steamcmd.tar.gz
    if [[ -f ~/.steam/steamcmd.sh ]]; then
        mkdir -p ~/.local/bin
        rm -f ~/.local/bin/steamcmd
        printf '#!/usr/bin/bash\nexec ~/.steam/steamcmd.sh "$@"\n' > ~/.local/bin/steamcmd
        chmod +x ~/.local/bin/steamcmd
    fi
    echo "SteamCMD was installed."

[group("steam")]
remove-steamcmd:
    rm -f "$HOME/.local/bin/steamcmd"
    rm -f "$HOME/.steam/steamcmd.sh"
    echo "SteamCMD has been uninstalled."

[group("steam")]
install-scopebuddy:
    run0 curl -Lo /usr/local/bin/scopebuddy https://raw.githubusercontent.com/HikariKnight/ScopeBuddy/refs/heads/main/bin/scopebuddy
    run0 chmod +x /usr/local/bin/scopebuddy
    run0 ln -s scopebuddy /usr/local/bin/scb
    echo "Scopebuddy was installed."
    echo "Tip: Install Scopebuddy gui (flatpak install --system io.github.rfrench3.scopebuddy-gui) for GUI configuration"

[group("steam")]
remove-scopebuddy:
    run0 rm /usr/local/bin/scopebuddy
    run0 rm /usr/local/bin/scb
    echo "Scopebuddy was removed."

[group("steam")]
install-millennium:
    /usr/share/spacefin/scripts/millennium-patch.sh

[group("steam")]
remove-millennium:
    rm -rf ~/.local/share/Millennium
    rm -f /var/tmp/millennium
    rm -f ~/.local/share/Steam/ubuntu12_32/libXtst.so.6
    rm -f ~/.local/share/Steam/ubuntu12_64/libXtst.so.6
    rm -f ~/.local/share/Steam/ubuntu12_64/libmillennium_hhx64.so

    echo "Millennium was removed."
    echo "Restart Steam to apply changes"

[group("steam")]
install-bigpicture-session:
    #! /bin/run0 /bin/bash
    WORK_DIR=$(mktemp -d)
    mkdir -p "${WORK_DIR}/usr/share/wayland-sessions"
    mkdir -p "${WORK_DIR}/usr/share/gamescope-session-plus/sessions.d"

    curl -L -o "${WORK_DIR}/usr/share/wayland-sessions/gamescope-session-steam.desktop" "https://raw.githubusercontent.com/OpenGamingCollective/gamescope-session-steam/refs/heads/main/usr/share/wayland-sessions/gamescope-session-steam.desktop"
    curl -L -o "${WORK_DIR}/usr/share/gamescope-session-plus/sessions.d/steam" "https://raw.githubusercontent.com/OpenGamingCollective/gamescope-session-steam/refs/heads/main/usr/share/gamescope-session-plus/sessions.d/steam"
    /var/home/vlasta/Dokumenty/code/Spacefin/Spacefin/system_files/usr/lib/pacman-bootc/pacman-bootc-build "${WORK_DIR}" "big-picture-session" &>/dev/null
    #/usr/lib/pacman-bootc/pacman-bootc-build "${WORK_DIR}" "big-picture-session" &>/dev/null

    rm -r "${WORK_DIR}"
    echo ""
    echo "Steam big picture session installed!"
    echo "Log out to open it"

[group("steam")]
remove-bigpicture-session:
    run0 /usr/lib/pacman-bootc/pacman-bootc-remove big-picture-session &>/dev/null
    echo ""
    echo "Steam big picture session was removed!"

[group("steam")]
install-deckloader:
    /usr/share/spacefin/scripts/deckloader-patch.sh

[group("steam")]
remove-deckloader:
    #!/usr/bin/bash
    HOMEBREW_FOLDER="/home/${USER}/homebrew"

    run0 systemctl disable --now plugin_loader.service > /dev/null
    run0 rm -f "/var/home/${USER}/.config/systemd/user/plugin_loader.service"
    run0 rm -f "/etc/systemd/system/plugin_loader.service"
    run0 rm -r "${HOMEBREW_FOLDER}"
    run0 rm "/var/home/${USER}/.steam/steam/.cef-enable-remote-debugging"

    echo "Deckloader was removed."
    echo "Restart Steam to apply changes"


[group("setups")]
install-system-flatpaks:
    flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    xargs -a /usr/share/spacefin/flatpaks.list flatpak install --system -y

[group("setups")]
install-recommended-flatpaks:
    #!/bin/bash
    GEFORCE_URL="https://international.download.nvidia.com/GFNLinux/GeForceNOWSetup.bin"
    GEFORCE_BIN="/tmp/GeForceNOWSetup.bin"

    flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    xargs -a /usr/share/spacefin/flatpaks-recommended.list flatpak install --system -y

    curl -L "$GEFORCE_URL" -o "$GEFORCE_BIN"
    chmod +x "$GEFORCE_BIN"
    "$GEFORCE_BIN"
