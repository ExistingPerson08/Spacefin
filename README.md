Bluefin based image with COSMIC desktop installed. **This image is WIP!**

## Features

 - Latest or tagged cosmic desktop

And coming soon:
 - Separate cosmic and gnome apps like Voyager OS does with XFCE
 - Setup ujust (modified rebase-helper, setup-cosmic-flatpak-repo)
 - Themes and more

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

