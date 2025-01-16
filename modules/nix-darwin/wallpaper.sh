#!/usr/bin/env bash

# Find image.
DOMAIN="http://www.bing.com"
LOCATION=$(curl -s "$DOMAIN/HPImageArchive.aspx?format=js&idx=0&n=50" | jq -re '.images[0].url')

# Download image.
WALLPAPER_URL="$DOMAIN$LOCATION"
WALLPAPER_PATH="/tmp/wallpaper.jpg"
curl -s "$WALLPAPER_URL" -o "$WALLPAPER_PATH"

# Use image as desktop background.
osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_PATH\""
