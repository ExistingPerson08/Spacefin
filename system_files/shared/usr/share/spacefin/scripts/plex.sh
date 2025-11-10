#!/bin/bash

CONFIG_DIR="$HOME/Aplikace/Plex/plexconfig"
TRANSCODE_DIR="$HOME/Aplikace/Plex/transcode"
MOVIES_DIR="$HOME/Videa/movies"
MUSIC_DIR="$HOME/Hudba"
TV_DIR="$HOME/Aplikace/Plex/tv"
PLEX_USER_ID=$(id -u)
PLEX_GROUP_ID=$(id -g)
CONTAINER_NAME="plex"

mkdir -p "$CONFIG_DIR" "$TRANSCODE_DIR" "$MOVIES_DIR" "$MUSIC_DIR" "$TV_DIR"

podman rm -f $CONTAINER_NAME 2>/dev/null || true

podman run -d --name $CONTAINER_NAME --net=host \
  -v /run/dbus:/run/dbus:ro \
  -v "$CONFIG_DIR":/config:Z \
  -v "$TRANSCODE_DIR":/transcode:Z \
  -v "$MOVIES_DIR":/movies:Z \
  -v "$MUSIC_DIR":/music:Z \
  -v "$TV_DIR":/tv:Z \
  -e PLEX_UID=$PLEX_USER_ID \
  -e PLEX_GID=$PLEX_GROUP_ID \
  docker.io/linuxserver/plex:latest

SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/plex.service" <<EOF
[Unit]
Description=Plex Media Server container
After=network.target

[Service]
Restart=always
ExecStart=/usr/bin/podman start -a $CONTAINER_NAME
ExecStop=/usr/bin/podman stop -t 10 $CONTAINER_NAME

[Install]
WantedBy=default.target
EOF

# Přečtení nové jednotky, povolení a start služby
systemctl --user daemon-reload
systemctl --user enable plex.service
systemctl --user start plex.service

echo "Plex Media Server was installed and set up."
echo "Web interface is avaible at http://localhost:32400/web"
