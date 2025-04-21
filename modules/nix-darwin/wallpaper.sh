#!/usr/bin/env bash

# Find image.
DOMAIN="http://www.bing.com"
LOCATION=$(curl -s "$DOMAIN/HPImageArchive.aspx?format=js&idx=0&n=50" | jq -re '.images[0].url')

# Download image.
WALLPAPER_URL="$DOMAIN$LOCATION"
WALLPAPER_PATH="/tmp/wallpaper.jpg"
echo "Downloading wallpaper from $WALLPAPER_URL to $WALLPAPER_PATH"
curl -s "$WALLPAPER_URL" -o "$WALLPAPER_PATH"

# Create Photos album, import image, and set as desktop wallpaper.
osascript <<EOF
tell application "Photos"
    activate
    delay 3

    set albumExists to false
    try
        set albumExists to (exists album "Wallpapers")
    end try

    if not albumExists then
        make new album named "Wallpapers"
    end if

    import POSIX file "/tmp/wallpaper.jpg" into album "Wallpapers" skip check duplicates yes

    delay 3
    quit
end tell

tell application "Finder" to set desktop picture to POSIX file "/tmp/wallpaper.jpg"

EOF
