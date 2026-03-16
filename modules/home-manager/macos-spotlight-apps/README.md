# macOS Spotlight Apps

macOS Spotlight doesn't index symlinks, so Nix-installed GUI apps aren't discoverable via Cmd+Space.

This module creates wrapper apps in `~/Applications/Nix/` - minimal `.app` bundles containing the `Info.plist`, icon, and a shell script that opens the real app in the Nix store. Spotlight indexes these wrappers, making Nix apps launchable normally.

Inspired by [hraban/mac-app-util](https://github.com/hraban/mac-app-util).
