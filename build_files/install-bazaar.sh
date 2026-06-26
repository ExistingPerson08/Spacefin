_pkgname="bazaar"
REPO_URL="https://github.com/kolunmi/bazaar.git"
BUILD_DIR="build"

git clone "$REPO_URL" bazaar
cd bazaar
PKGVER=$(git describe --long --tags --abbrev=7 | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g')
cd ..

meson setup "bazaar" "$BUILD_DIR" \
    --prefix=/usr \
    --buildtype=release \
    -Dhardcoded_main_config_path="/usr/share/spacefin/bazaar/main.yaml"

meson compile -C "$BUILD_DIR"
meson install -C "$BUILD_DIR"
rm "$BUILD_DIR"
