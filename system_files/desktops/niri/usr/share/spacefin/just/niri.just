reset-niri-config:
    # Copy config
    # TO-DO: Add reset to spacefin-cli
    cp ~/.config/niri/config.kdl ~/.backup/niri/config.kdl
    cp ~/.config/ghostty/config ~/.backup/ghostty/config

    rm -r ~/.config/niri/
    rm ~/.config/ghostty/config

    cp -r /etc/skel/.config/niri/ ~/.config/
    cp /etc/skel/.config/ghostty/config ~/.config/ghostty/
