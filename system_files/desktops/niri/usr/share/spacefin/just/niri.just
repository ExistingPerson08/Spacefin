reset-niri-config:
    # Copy config
    # TO-DO: Add reset to spacefin-cli

    rm -r ~/.config/niri/
    rm ~/.config/ghostty/config

    cp -r /etc/skel/.config/niri/ ~/.config/
    cp /etc/skel/.config/ghostty/config ~/.config/ghostty/
