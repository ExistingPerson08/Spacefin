#!/bin/bash

FIRSTRUN="/etc/first-run"

if [ -f "$FIRSTRUN" ]; then
    exit 0
fi

# Convert wpa_supplicant to iwd
for file in /etc/NetworkManager/system-connections/*.nmconnection; do
    [ -e "$file" ] || continue

    ssid=$(awk -F= '/^\[wifi\]/{f=1} /^\[/{if($0!="[wifi]")f=0} f&&/^ssid=/{print $2}' "$file" | tr -d '"'\''')
    psk=$(awk -F= '/^\[wifi-security\]/{f=1} /^\[/{if($0!="[wifi-security]")f=0} f&&/^psk=/{print $2}' "$file")

    [ -z "$ssid" ] && ssid=$(awk -F= '/^\[connection\]/{f=1} /^\[/{if($0!="[connection]")f=0} f&&/^id=/{print $2}' "$file" | tr -d '"'\''')

    if [ -n "$ssid" ] && [ -n "$psk" ]; then
        iwd_file="/var/lib/iwd/$ssid.psk"
        printf "[Security]\nPassphrase=%s\n" "$psk" > "$iwd_file"
        chmod 600 "$iwd_file"
    fi
done

systemctl restart iwd

# Wait for network
echo "Waiting for network connection..." > /dev/tty1

until ping -c 1 8.8.8.8 &>/dev/null; do
    sleep 1
done

echo "Runing first-run setup..." > /dev/tty1

# Install flatpaks
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
xargs -a /usr/share/spacefin/flatpaks.list flatpak install flathub --system -y

# Fix printing on LibreOffice
flatpak override \
  --system \
  --socket=cups \
  --socket=session-bus \
  org.libreoffice.LibreOffice

# Allow MangoHUD config for Flatpaks
flatpak override \
  --filesystem=xdg-config/MangoHud:create \
  --filesystem=xdg-config/vkBasalt:create

# Fix permissions for Protontricks
flatpak override \
  --filesystem=~/.local/share/Steam \
  --filesystem=/var/mnt \
  --filesystem=/run/media \
  com.github.Matoking.protontricks

# Allow smartphone's passkey for chrome browsers
for app in \
    "org.chromium.Chromium"  \
    "io.github.ungoogled_software.ungoogled_chromium"  \
    "com.vivaldi.Vivaldi"  \
    "com.opera.Opera"  \
    "com.opera.opera-gx"  \
    "com.brave.Browser"  \
    "com.microsoft.Edge"
do
    flatpak override --system-talk-name=org.bluez $app
done && unset -v app

# Install browser policies
mkdir -p "/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies"
cp /usr/share/spacefin/browser/policies.json "/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies/"

mkdir -p "/var/lib/flatpak/extension/app.zen_browser.zen.systemconfig/x86_64/stable/policies"
cp /usr/share/spacefin/browser/policies.json "/var/lib/flatpak/extension/app.zen_browser.zen.systemconfig/x86_64/stable/policies/"

touch "$FIRSTRUN"
