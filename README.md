<div align="center">
 <img src="assets/desktop.png" width="80%">
</div>
<br>

<div align="center">
 <b><big>This is no longer mantained and splited into these projects: <a href="https://gitlab.com/rakuos/images/rakuos-niri)">RakuOS Niri</a>, <a href="https://github.com/ExistingPerson08/.dotfiles">.dotfiles</a> and <a href="https://github.com/ExistingPerson08/gamescope-session-pp">gamescope session++</a>!</big></b>
</div>
<br>

Spacefin is my personal custom Arch bootc image with (not only) COSMIC desktop installed. **Note that this is WIP personal opinionated image so things are likely going to change or break!**

## Features

 - Cosmic and niri
 - Codecs and drivers out-of-the box
 - Preconfigured Niri setup with [Dank material shell](https://danklinux.com/)
 - Ananicy-cpp with [CachyOS's](https://github.com/CachyOS/ananicy-rules) and [custom](https://github.com/ExistingPerson08/ExistingRules) rules
 - Java preinstalled and set for running .jar files
 - Homebrew, Docker and Distrobox preinstalled
 - Restic and rclone out-of-the box
 - Fish preinstalled and set
 - Quickemu for virtualization
 - CachyOS's optized repos and linux-zen kernel
 - Gaming stack (Steam, gamescope, gamescope Big Picture...)
 - It just works (mostly (maybe...))

## Installation

You can switch to Spacefin from Fedora Silverblue or Bluefin with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin:latest
```

After reboot, system flatpaks will be automaticly installed and your wifi passwords will be converted to iwd so please be patient and backup passwords.
