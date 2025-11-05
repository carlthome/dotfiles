#!/usr/bin/env bash

# Find image.
DOMAIN="http://www.bing.com"
LOCATION=$(curl -s "$DOMAIN/HPImageArchive.aspx?format=js&idx=0&n=1" | jq -re '.images[0].url')

# Extract image ID.
ID=$(echo "$LOCATION" | grep -oE 'id=[^&]+' | cut -d'=' -f2 | head -n1)

# Download image.
mkdir -p ~/Pictures/Wallpapers
WALLPAPER_FILE="$HOME/Pictures/Wallpapers/$ID"
if [ ! -f "$WALLPAPER_FILE" ]; then
	WALLPAPER_URL="$DOMAIN$LOCATION"
	echo "Downloading $WALLPAPER_URL to $WALLPAPER_FILE"
	curl -s "$WALLPAPER_URL" -o "$WALLPAPER_FILE"
fi

# Set desktop wallpaper.
osascript <<EOF
tell application "Finder"
set desktop picture to POSIX file "$WALLPAPER_FILE"
end tell
EOF
