#!/bin/bash

HOMEBREW_FOLDER="/home/${USER}/homebrew"

BRANCH="release"

echo "Creating file structure"
rm -rf "${HOMEBREW_FOLDER}/services"
mkdir -p "${HOMEBREW_FOLDER}/services"
mkdir -p "${HOMEBREW_FOLDER}/plugins"
touch "/var/home/${USER}/.steam/steam/.cef-enable-remote-debugging"

echo "Finding latest $BRANCH"
RELEASE=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )
DOWNLOADURL=$(jq -r '.assets[].browser_download_url | select(endswith("PluginLoader"))' <<< ${RELEASE})

echo "Installing version $VERSION"
curl -L $DOWNLOADURL -o ${HOMEBREW_FOLDER}/services/PluginLoader 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/'
chmod +x ${HOMEBREW_FOLDER}/services/PluginLoader

echo $VERSION > ${HOMEBREW_FOLDER}/services/.loader.version

echo "70" ; echo "# Killing plugin_loader if it exists" ;
systemctl --user stop plugin_loader 2> /dev/null
systemctl --user disable plugin_loader 2> /dev/null
systemctl stop plugin_loader 2> /dev/null
systemctl disable plugin_loader 2> /dev/null

curl -L https://raw.githubusercontent.com/SteamDeckHomebrew/decky-loader/main/dist/plugin_loader-${BRANCH}.service  --output ${HOMEBREW_FOLDER}/services/plugin_loader-${BRANCH}.service
cat > "${HOMEBREW_FOLDER}/services/plugin_loader-backup.service" <<- EOM
[Unit]
Description=SteamDeck Plugin Loader
After=network-online.target
Wants=network-online.target
[Service]
Type=simple
User=root
Restart=always
ExecStart=${HOMEBREW_FOLDER}/services/PluginLoader
WorkingDirectory=${HOMEBREW_FOLDER}/services
KillSignal=SIGKILL
Environment=PLUGIN_PATH=${HOMEBREW_FOLDER}/plugins
Environment=LOG_LEVEL=INFO
[Install]
WantedBy=multi-user.target
EOM

if [[ -f "${HOMEBREW_FOLDER}/services/plugin_loader-${BRANCH}.service" ]]; then
    printf "Grabbed latest ${BRANCH} service.\n"
    sed -i -e "s|\${HOMEBREW_FOLDER}|${HOMEBREW_FOLDER}|" "${HOMEBREW_FOLDER}/services/plugin_loader-${BRANCH}.service"
    run0 cp -f "${HOMEBREW_FOLDER}/services/plugin_loader-${BRANCH}.service" "/etc/systemd/system/plugin_loader.service"
else
    printf "Could not curl latest ${BRANCH} systemd service, using built-in service as a backup!\n"
    run0 rm -f "/etc/systemd/system/plugin_loader.service"
    run0 cp "${HOMEBREW_FOLDER}/services/plugin_loader-backup.service" "/etc/systemd/system/plugin_loader.service"
fi

mkdir -p ${HOMEBREW_FOLDER}/services/.systemd
cp ${HOMEBREW_FOLDER}/services/plugin_loader-${BRANCH}.service ${HOMEBREW_FOLDER}/services/.systemd/plugin_loader-${BRANCH}.service
cp ${HOMEBREW_FOLDER}/services/plugin_loader-backup.service ${HOMEBREW_FOLDER}/services/.systemd/plugin_loader-backup.service
rm ${HOMEBREW_FOLDER}/services/plugin_loader-backup.service ${HOMEBREW_FOLDER}/services/plugin_loader-${BRANCH}.service

systemctl daemon-reload
systemctl start plugin_loader
systemctl enable plugin_loader

echo "Deck loader was installed!";
echo "Restart Steam to Big Picture mode to apply changes"
