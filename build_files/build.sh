#!/bin/bash

set -ouex pipefail

# Install COSMIC desktop and exclude non-cosmic apps
dnf install -y @cosmic-desktop @cosmic-desktop-apps --exclude=okular,rhythmbox,thunderbird,nheko,ark



