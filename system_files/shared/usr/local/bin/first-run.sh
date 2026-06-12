#!/bin/bash

FIRSTRUN="/etc/first-run"

if [ -f "$FIRSTRUN" ]; then
    exit 0
fi

# Wait for network
echo "Waiting for network connection..." > /dev/tty1

until ping -c 1 8.8.8.8 &>/dev/null; do
    sleep 1
done

echo "Runing first-run setup..." > /dev/tty1

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

# Install flatpaks
flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -a /usr/share/spacefin/flatpaks.list flatpak install flathub --system -y

# Install browser policies
mkdir -p "/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies"
cp /usr/share/spacefin/browser/policies.json "/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies/"

mkdir -p "/var/lib/flatpak/extension/app.zen_browser.zen.systemconfig/x86_64/stable/policies"
cp /usr/share/spacefin/browser/policies.json "/var/lib/flatpak/extension/app.zen_browser.zen.systemconfig/x86_64/stable/policies/"

touch "$FIRSTRUN"
