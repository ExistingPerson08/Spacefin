<div align="center">
 <h1>⚠️ THIS IMAGE IS CURRENTLY IN ALPHA ⚠️</h1>
 <img src="assets/desktop.png" width="80%">
</div>
<br>

Spacefin is custom Fedora Atomic image with COSMIC desktop installed. 

## Features

 - Latest or tagged cosmic desktop
 - Codecs and drivers out-of-the box
 - Custom just commands
 - Patched `switcheroo-control`, `mesa` and `xwayland`
 - Kernel with hardware patches
 - System76-schenduler enabled by default
 - Java preinstalled and set for running .jar files
 - Homebrew, Docker and Distrobox preinstalled
 - Restic and rclone out-of-the box
 - All shells (fish, bash, zsh) preinstalled

## Editions

### Main (Cosmic)

 - Custom COSMIC theme
    - with focus on tilling and minimalism
 - Spacefin-cli for changing themes
 - Preconfigured Zed and VSCodium
 - Gnome Boxes and quickemu for virtualization
 - Curated set of open-source apps

If you want to install main eddition, rebase from Fedora Cosmic Atomic with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin:latest
```

### GNOME

 - Preconfigured GNOME desktop
    - GSConnect set up by default
    - Layout customized for touchscreen
    - patches to enable fractional scalling, VRR and more
    - Preinstalled useful extensions
    - [Hanabi extension](https://github.com/jeffshee/gnome-ext-hanabi) for live wallpapers
 - Curated set of touchscreen-friendly open-source apps

If you want to install GNOME eddition, rebase from Fedora Silverblue or Bluefin with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin-gnome:latest
```

### Cinnamon

- Almost vanilla cinnamon desktop
- Steam and lutris with Gamescope session
- VLC, Thunderbird and Edge for media
- Wine dobble-click to run .exe

If you want to install GNOME eddition, rebase from Fedora Silverblue with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin-cinnamon:latest
```

## Contributing

Ideas and pull requests are welcome 🎉. I would also appreciate a suggestion for a better name 😉.

## Screenshots

<div align="center">
<img src="assets/Gnome.png" width="70%">
</div>
