#!/bin/bash

set -ouex pipefail

# -- DANKSEARCH --
VERSION=$(curl -s "https://api.github.com/repos/AvengeMedia/danksearch/releases/latest" | grep -oP '"tag_name":\s*"v\K[^"]+')
curl -sL "https://github.com/AvengeMedia/danksearch/releases/download/v${VERSION}/dsearch-linux-amd64.gz" | gzip -d > /usr/bin/dsearch
chmod 755 /usr/bin/dsearch
mkdir -p /usr/lib/systemd/user /usr/share/licenses/dsearch-bin /usr/share/doc/dsearch-bin

_url="https://raw.githubusercontent.com/AvengeMedia/danksearch/v${VERSION}"
curl -sL "$_url/dsearch.service" -o /usr/lib/systemd/user/dsearch.service
curl -sL "$_url/LICENSE" -o /usr/share/licenses/dsearch-bin/LICENSE

chmod 644 /usr/lib/systemd/user/dsearch.service /usr/share/licenses/dsearch-bin/LICENSE

# -- DMS-GREETER --
tmp_dir=$(mktemp -d)
git clone --depth=1 "https://github.com/AvengeMedia/DankMaterialShell.git" "$tmp_dir"

mkdir -p /usr/share/quickshell/dms-greeter /usr/bin /usr/share/doc/dms-greeter /var/cache/dms-greeter

cp -r "$tmp_dir/quickshell"/* /usr/share/quickshell/dms-greeter/
cp "$tmp_dir/quickshell/Modules/Greetd/assets/dms-greeter" /usr/bin/dms-greeter

chmod 755 /usr/bin/dms-greeter
chmod 750 /var/cache/dms-greeter
rm -rf /usr/share/quickshell/dms-greeter/.git*
rm -rf "$tmp_dir"

chown greeter:greeter /var/cache/dms-greeter
chmod 750 /var/cache/dms-greeter

printf '[terminal]\nvt = 1\n\n[default_session]\nuser = "greeter"\ncommand = "/usr/bin/dms-greeter --command niri"\n' | sudo tee /etc/greetd/config.toml

# -- DANK CALENDAR --
VERSION=$(curl -s "https://api.github.com/repos/AvengeMedia/dankcalendar/releases/latest" | grep -oP '"tag_name":\s*"v\K[^"]+')

URL_REL="https://github.com/AvengeMedia/dankcalendar/releases/download/v${VERSION}"
URL_RAW="https://raw.githubusercontent.com/AvengeMedia/dankcalendar/v${VERSION}"
DESKTOP_ID="com.danklinux.dankcalendar"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

curl -L -O "${URL_REL}/dankcalendar-shell-${VERSION}.tar.gz"
curl -L -O "${URL_REL}/dcal-completions-${VERSION}.tar.gz"
curl -L -o "dcal-linux.gz" "${URL_REL}/dcal-linux-amd64.gz"
curl -L -O "${URL_RAW}/LICENSE"
curl -L -O "${URL_RAW}/README.md"
curl -L -o "${DESKTOP_ID}.desktop" "${URL_RAW}/assets/${DESKTOP_ID}.desktop"
curl -L -o "dcal.service" "${URL_RAW}/assets/systemd/dcal.service"

gunzip "dcal-linux.gz"
tar -xzf "dankcalendar-shell-${VERSION}.tar.gz"
tar -xzf "dcal-completions-${VERSION}.tar.gz"

install -Dm755 "dcal-linux" "/usr/bin/dcal"
install -Dm644 "dcal"  "/usr/share/bash-completion/completions/dcal"
install -Dm644 "_dcal" "/usr/share/zsh/site-functions/_dcal"
install -Dm644 "dcal.fish" "/usr/share/fish/vendor_completions.d/dcal.fish"

install -dm755 "/usr/share/quickshell/dankcal"
cp -r dankcal/. "/usr/share/quickshell/dankcal/"
install -Dm644 "dankcal/assets/dankcalendar.svg" "/usr/share/icons/hicolor/scalable/apps/dankcalendar.svg"
install -Dm644 "${DESKTOP_ID}.desktop" "/usr/share/applications/${DESKTOP_ID}.desktop"
install -Dm644 "dcal.service" "/usr/lib/systemd/user/dcal.service"
install -Dm644 "LICENSE" "/usr/share/licenses/dankcalendar/LICENSE"
cd ..
rm -rf "$TMP_DIR"

# -- WL-FREEZE --
tmp_dir=$(mktemp -d)
git clone --depth=1 "https://github.com/Zerodya/wl-freeze" "$tmp_dir"

mkdir -p /usr/bin \
         /usr/share/licenses/wl-freeze \
         /usr/share/bash-completion/completions \
         /usr/share/fish/completions \

cp "$tmp_dir/wl-freeze" /usr/bin/wl-freeze
cp "$tmp_dir/LICENSE" /usr/share/licenses/wl-freeze/LICENSE
cp "$tmp_dir/completions/bash/wl-freeze" /usr/share/bash-completion/completions/wl-freeze
cp "$tmp_dir/completions/fish/wl-freeze.fish" /usr/share/fish/completions/wl-freeze.fish

chmod 755 /usr/bin/wl-freeze
chmod 644 /usr/share/licenses/wl-freeze/LICENSE \
          /usr/share/bash-completion/completions/wl-freeze \
          /usr/share/fish/completions/wl-freeze.fish

rm -rf "$tmp_dir"
