#!/bin/bash

set -ouex pipefail

git clone https://github.com/ExistingPerson08/ExistingRules /etc/ananicy.d
rm /etc/ananicy.d/LICENCE
rm /etc/ananicy.d/PKGBUILD
rm /etc/ananicy.d/README.md
rm -r /etc/ananicy.d/.git
