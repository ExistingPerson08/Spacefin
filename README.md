<div align="center">
 <img src="assets/desktop.png" width="80%">
</div>
<br>

Spacefin is my personal custom Arch bootc image with (not only) COSMIC desktop installed. **Note that this is WIP personal opinionated image so things are likely going to change or break!**

## Features

 - Cosmic or Niri wm
 - Codecs and drivers out-of-the box
 - Preconfigured Niri setup with [Dank material shell](https://danklinux.com/)
 - Ananicy-cpp with [CachyOS's](https://github.com/CachyOS/ananicy-rules) and [custom](https://github.com/ExistingPerson08/ExistingRules) rules
 - Java preinstalled and set for running .jar files
 - Homebrew, Docker and Distrobox preinstalled
 - Restic and rclone out-of-the box
 - All shells (fish, bash, zsh) preinstalled
 - Gnome Boxes and quickemu for virtualization
 - CachyOS's optized repos and linux-zen kernel
 - Gaming stack (Steam, gamescope, gamescope session...)

## Installation

You can switch to Spacefin from Fedora Silverblue or Bluefin with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin:latest
```

