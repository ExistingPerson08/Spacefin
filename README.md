# ⚠️ THIS IMAGE IS CURRENTLY IN ALPHA ⚠️

[Bluefin](https://github.com/ublue-os/bluefin) based image with COSMIC desktop installed. 

## About

 - Latest or tagged cosmic desktop
 - Custom just commands

And coming soon:
 - Separate cosmic and gnome apps like Voyager OS does with XFCE
 - Themes and more
 - Standalone COSMIC only image that is not based on Bluefin but on [Universal Blue main image](https://github.com/ublue-os/main) that will be main Spacefin image.
 - "Hybrid" image with both COSMIC and GNOME that will replace current "main" image

## Contributing

Ideas and pull requests are welcome 🎉. I would also appreciate a suggestion for a better name 😉.

## How to install

There are 2 variants: Main and experimental.

Main image is based on Bluefin stable and has tagged Cosmic desktop. You can rebase from Bluefin or Fedora Silverblue with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin:latest
```

Experimental image is based on modified Bluefin-dx stable daily and has latest (nightly) Cosmic desktop from COPR. You can rebase from Bluefin or Fedora Silverblue with:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/existingperson08/spacefin-exp:latest
```

