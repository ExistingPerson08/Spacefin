#!/bin/bash
# Remove webapp
set -e

ICON_DIR="$HOME/.local/share/icons/webapps"
DESKTOP_DIR="$HOME/.local/share/applications/"

# Find all web apps
WEB_APPS=()
while IFS= read -r -d '' file; do
  if grep -q '^Exec=.*open-webapp.*' "$file"; then
    WEB_APPS+=("$(basename "${file%.desktop}")")
  fi
done < <(find "$DESKTOP_DIR" -name '*.desktop' -print0)

if ((${#WEB_APPS[@]})); then
  IFS=$'\n' SORTED_WEB_APPS=($(sort <<<"${WEB_APPS[*]}"))
  unset IFS

  # List of apps
  echo "Choose which webapp remove"
  echo ""
  for i in "${!SORTED_WEB_APPS[@]}"; do
    echo "[$((i+1))] ${SORTED_WEB_APPS[$i]}"
  done
  echo ""

  read -p "Enter number to remove: " CHOICE

  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= ${#SORTED_WEB_APPS[@]} )); then
    APP_NAME="${SORTED_WEB_APPS[$((CHOICE-1))]}"
  else
    echo "Invalid selection."
    exit 1
  fi
else
  echo "No web apps to remove."
  exit 1
fi

echo ""
rm -f "$DESKTOP_DIR/$APP_NAME.desktop"
rm -f "$ICON_DIR/$APP_NAME.png"
echo "Removed $APP_NAME"
