flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -a /usr/share/spacefin/flatpaks.list flatpak install --system -y

mkdir -p "/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies"
cp /usr/share/spacefin/browser/policies.json "/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies/"

mkdir -p "/var/lib/flatpak/extension/app.zen_browser.zen.systemconfig/x86_64/stable/policies"
cp /usr/share/spacefin/browser/policies.json "/var/lib/flatpak/extension/app.zen_browser.zen.systemconfig/x86_64/stable/policies/"
