# ⚠️ THIS IMAGE IS CURRENTLY IN ALPHA ⚠️

Spacefin is [Bluefin](https://github.com/ublue-os/bluefin) inspired image with COSMIC desktop installed. 

## Features

 - Latest or tagged cosmic desktop
 - Custom just commands
 - Standalone COSMIC only image
 - "Hybrid" image with both COSMIC and GNOME

And coming soon:
 - Separate cosmic and gnome apps like Voyager OS does with XFCE
 - Themes and more

## Contributing

Ideas and pull requests are welcome 🎉. I would also appreciate a suggestion for a better name 😉.

## How to install

There are 3 variants: Main, hybrid and experimental.

Main image is based on [Universal Blue main image](https://github.com/ublue-os/main) and has only COSMIC desktop. It has most features that Bluefin has. **This image does not recive updates now and most things do not work!**. You can rebase from Fedora COSMIC atomic with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin:latest
```

Hybrid image is based on Bluefin stable and has tagged Cosmic desktop and GNOME 48. You can rebase from Bluefin or Fedora Silverblue with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin-hybrid:latest
```

Experimental image is based on modified Bluefin-dx stable daily and has latest (nightly) Cosmic desktop from COPR and latest GNOME desktop from Fedora repos. You can rebase from Bluefin or Fedora Silverblue with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin-exp:latest
```

