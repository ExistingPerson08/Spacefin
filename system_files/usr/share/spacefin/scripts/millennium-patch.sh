#!/usr/bin/env bash
set -e
INSTALL_DIR="${HOME}/.local/share/Millennium"
STEAM_DIR="${HOME}/.local/share/Steam"
TMP_DIR="/tmp/millennium_install"
VAR_TMP_DIR="/var/tmp/millennium"

LATEST_TAG=$(curl -sL "https://api.github.com/repos/SteamClientHomebrew/Millennium/releases/latest" | jq -r .tag_name)
DOWNLOAD_URL="https://github.com/SteamClientHomebrew/Millennium/releases/download/${LATEST_TAG}/millennium-${LATEST_TAG}-linux-x86_64.tar.gz"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
curl -# -L "$DOWNLOAD_URL" -o "$TMP_DIR/millennium.tar.gz"

tar -xzf "$TMP_DIR/millennium.tar.gz" -C "$TMP_DIR"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -r "$TMP_DIR/usr/lib/millennium/"* "$INSTALL_DIR/"

cd "$INSTALL_DIR"
for file in libmillennium*; do
    if [ -f "$file" ]; then
        sed -i 's|/usr/lib/millennium|/var/tmp/millennium|g' "$file"
    fi
done

chmod +x libmillennium* 2>/dev/null || true
rm -rf "$VAR_TMP_DIR"
ln -sf "$INSTALL_DIR" "$VAR_TMP_DIR"
mkdir -p "${STEAM_DIR}/ubuntu12_32" "${STEAM_DIR}/ubuntu12_64"

rm -f "${STEAM_DIR}/package/beta"
ln -sf "$INSTALL_DIR/libmillennium_bootstrap_x86.so" "${STEAM_DIR}/ubuntu12_32/libXtst.so.6"
ln -sf "$INSTALL_DIR/libmillennium_bootstrap_hhx64.so" "${STEAM_DIR}/ubuntu12_64/libXtst.so.6"
ln -sf "$INSTALL_DIR/libmillennium_hhx64.so" "${STEAM_DIR}/ubuntu12_64/libmillennium_hhx64.so"
rm -rf "$TMP_DIR"

echo "Millennium was installed."
echo "Restart steam to apply changes"
