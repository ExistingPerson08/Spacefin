#!/bin/bash

set -ouex pipefail

git clone https://github.com/ExistingPerson08/ExistingRules /etc/ananicy.d
rm -f /etc/ananicy.d/LICENCE
rm -f /etc/ananicy.d/PKGBUILD
rm -f /etc/ananicy.d/README.md
rm -r /etc/ananicy.d/.git
