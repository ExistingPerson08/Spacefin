#!/bin/bash

FIRSTRUN="$HOME/.local/share/fist-run"
SRC_DIR="/usr/share/spacefin/templates/"

if [ -f "$FIRSTRUN" ]; then
    exit 0
fi

# Load xdg configuration
if [ -f "$HOME/.config/user-dirs.dirs" ]; then
    source "$HOME/.config/user-dirs.dirs"
fi

# Copy templates
TEMP_DIR="$XDG_TEMPLATES_DIR"
DOCS_DIR="${XDG_DOCUMENTS_DIR}"
cp -rv "$SRC_DIR"/* "$TEMP_DIR/"

mkdir $HOME/Screenshots
mkdir $HOME/Applications
mkdir $HOME/Applications/Games
mkdir $XDG_DOCUMENTS_DIR/code
mkdir $XDG_DOCUMENTS_DIR/quickemu
mkdir $XDG_DOCUMENTS_DIR/notes

CODE="$(eval echo "$DOCS_DIR")/code"
NOTES="$(eval echo "$DOCS_DIR")/notes"
mkdir -p ~/.config/gtk-3.0
echo "file://$CODE Code" >> ~/.config/gtk-3.0/bookmarks
echo "file://$NOTES Notes" >> ~/.config/gtk-3.0/bookmarks

touch "$FIRSTRUN"
