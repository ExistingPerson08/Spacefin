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
    brew install lazygit uv gh
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

# Install SteamCMD - from Bazzite
get-steamcmd ACTION="":
    #!/usr/bin/bash
    get_status_token() {
        if [[ -f "$HOME/.steam/steamcmd.sh" ]] || [[ -f "$HOME/.local/bin/steamcmd" ]]; then
            echo "install"
        else
            echo "uninstall"
        fi
    }
    get_current_status() {
        if [[ "$(get_status_token)" == "install" ]]; then
            echo "Installed"
        else
            echo "Not Installed"
        fi
    }
    install_steamcmd() {
        if [[ $UID -eq 0 ]]; then
            echo >&2 "This ujust should not be run as root."
            exit 1
        fi
        echo 'Installing SteamCMD...'
        wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz
        mkdir -p ~/.steam
        tar -xvzf /tmp/steamcmd.tar.gz -C ~/.steam
        rm /tmp/steamcmd.tar.gz
        if [[ -f ~/.steam/steamcmd.sh ]]; then
            mkdir -p ~/.local/bin
            rm -f ~/.local/bin/steamcmd
            printf '#!/usr/bin/bash\nexec ~/.steam/steamcmd.sh "$@"\n' > ~/.local/bin/steamcmd
            chmod +x ~/.local/bin/steamcmd
        fi
    }
    uninstall_steamcmd() {
        rm -f "$HOME/.local/bin/steamcmd"
        rm -f "$HOME/.steam/steamcmd.sh"
        echo "SteamCMD has been uninstalled."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust get-steamcmd <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install SteamCMD"
        echo "  Use 'uninstall' to uninstall SteamCMD"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit $?
    elif [[ "$OPTION" == "install" ]]; then
        install_steamcmd
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_steamcmd
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}SteamCMD${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_steamcmd
                ;;
            "Uninstall")
                uninstall_steamcmd
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi
