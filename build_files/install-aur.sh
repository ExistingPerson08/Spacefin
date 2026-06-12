#!/bin/bash

set -ouex pipefail

# DSearch
curl -sL "https://github.com/AvengeMedia/danksearch/releases/download/v0.3.1/dsearch-linux-amd64.gz" | gzip -d > /usr/bin/dsearch
chmod 755 /usr/bin/dsearch
mkdir -p /usr/lib/systemd/user /usr/share/licenses/dsearch-bin /usr/share/doc/dsearch-bin

_url="https://raw.githubusercontent.com/AvengeMedia/danksearch/v0.3.1"
curl -sL "$_url/dsearch.service" -o /usr/lib/systemd/user/dsearch.service
curl -sL "$_url/LICENSE" -o /usr/share/licenses/dsearch-bin/LICENSE

chmod 644 /usr/lib/systemd/user/dsearch.service /usr/share/licenses/dsearch-bin/LICENSE

# DMS-greeter
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

#Wl-freeze
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
