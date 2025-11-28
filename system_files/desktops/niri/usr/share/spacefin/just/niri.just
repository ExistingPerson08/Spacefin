reset-niri-config:
    # Copy config
    # TO-DO: Set this to automatic for new users or niri first launch
    # TO-DO: Add reset to spacefin-cli
    cp ~/.config/niri/config.kdl ~/.backup/niri/config.kdl
    cp ~/.config/ghostty/config ~/.backup/ghostty/config

    rm -r ~/.config/niri/
    rm ~/.config/ghostty/config

    cp -r /usr/share/spacefin/niri-conf/niri/ ~/.config/
    cp /usr/share/spacefin/niri-conf/config ~/.config/ghostty/
