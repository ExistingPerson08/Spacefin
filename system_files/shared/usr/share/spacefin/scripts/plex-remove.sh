#!/bin/bash

CONTAINER_NAME="plex"
CONFIG_DIR="$HOME/Plex/plexconfig"
TRANSCODE_DIR="$HOME/Plex/transcode"
MOVIES_DIR="$HOME/Videos/movies"
MUSIC_DIR="$HOME/Music"
TV_DIR="$HOME/Videos/tv"
SERVICE_FILE="$HOME/.config/systemd/user/plex.service"

# Zastavení a odstranění systému služby
systemctl --user stop plex.service
systemctl --user disable plex.service
rm -f "$SERVICE_FILE"
systemctl --user daemon-reload

# Zastavení a odstranění kontejneru
podman rm -f $CONTAINER_NAME 2>/dev/null || true

# Odstranění adresářů s daty (dejte pozor, smaže data)
rm -rf "$CONFIG_DIR" "$TRANSCODE_DIR" "$MOVIES_DIR" "$MUSIC_DIR" "$TV_DIR"

echo "Plex Media Server byl odinstalován a všechna data byla odstraněna."
