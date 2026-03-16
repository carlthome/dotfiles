#!/usr/bin/env bash

create_launcher() {
	printf '#!/bin/bash\nopen "%s"\n' "$1"
}

src="$1"
dst="$2"

if [[ $dst != "$HOME/Applications/"* ]]; then
	echo "Error: target must be under ~/Applications/" >&2
	exit 1
fi

mkdir -p "$dst"
find "$dst" -maxdepth 1 -name "*.app" -type d -exec rm -rf {} +

# Create wrappers for each .app
for app in "$src"/*.app; do
	[ -e "$app" ] || continue

	# Resolve symlink to get actual app path
	app_source=$(readlink -f "$app")
	app_name=$(basename "$app_source")
	wrapper="$dst/$app_name"

	# Create wrapper structure
	mkdir -p "$wrapper/Contents/MacOS"
	mkdir -p "$wrapper/Contents/Resources"

	# Copy Info.plist
	if [ -f "$app_source/Contents/Info.plist" ]; then
		cp "$app_source/Contents/Info.plist" "$wrapper/Contents/"
	fi

	# Copy icons
	if [ -d "$app_source/Contents/Resources" ]; then
		find "$app_source/Contents/Resources" -maxdepth 1 -name "*.icns" \
			-exec cp {} "$wrapper/Contents/Resources/" \;
	fi

	# Create launcher script that opens the real app
	exe_name=$(basename "$app_source" .app)
	create_launcher "$app_source" >"$wrapper/Contents/MacOS/$exe_name"
	chmod +x "$wrapper/Contents/MacOS/$exe_name"
done
