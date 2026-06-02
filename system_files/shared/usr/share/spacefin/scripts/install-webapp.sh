#!/bin/bash
# Install webapp
set -e

ICON_DIR="$HOME/.local/share/icons/webapps"

echo -e "Create a webapp with .desktop file"
echo ""
read -p 'Name: ' APP_NAME
read -p 'Url (e.g. https://seznam.cz): ' APP_URL
if [[ ! $APP_URL =~ ^[a-zA-Z][a-zA-Z0-9+.-]*: ]]; then
  APP_URL="https://$APP_URL"
fi

# Try to fetch favicon automatically first.
FAVICON_URL="https://www.google.com/s2/favicons?domain=${APP_URL}&sz=128"
mkdir -p "$ICON_DIR"
if curl -fsSL -o "$ICON_DIR/$APP_NAME.png" "$FAVICON_URL" && [[ -s $ICON_DIR/$APP_NAME.png ]]; then
  ICON_REF="$APP_NAME.png"
else
  read -p 'Icon URL: ' ICON_REF
fi

CUSTOM_EXEC=""
MIME_TYPES=""
INTERACTIVE_MODE=true

# Resolve icon from URL or from a local icon name.
mkdir -p "$ICON_DIR"

if [[ -z $ICON_REF ]]; then
  ICON_REF="https://www.google.com/s2/favicons?domain=${APP_URL}&sz=128"
fi

if [[ $ICON_REF =~ ^https?:// ]]; then
  ICON_PATH="$ICON_DIR/$APP_NAME.png"
  if ! curl -fsSL -o "$ICON_PATH" "$ICON_REF" || [[ ! -s $ICON_PATH ]]; then
    echo "Error: Failed to download icon."
    exit 1
  fi
else
  ICON_PATH="$ICON_DIR/$ICON_REF"
fi

# Create application .desktop file
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"

cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=open-webapp $APP_URL
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

# Add mime types if provided
if [[ -n $MIME_TYPES ]]; then
  echo "MimeType=$MIME_TYPES" >>"$DESKTOP_FILE"
fi

chmod +x "$DESKTOP_FILE"

if [[ $INTERACTIVE_MODE == "true" ]]; then
  echo -e "Webapp created!\n"
fi
