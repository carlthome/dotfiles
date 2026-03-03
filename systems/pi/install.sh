#!/usr/bin/env bash
set -euo pipefail

# Build OS image.
nix build .#nixosConfigurations.pi.config.system.build.sdImage --print-build-logs

# Write image to device (check lsblk for correct device).
echo "Available devices:"
lsblk
read -rp "Enter device [/dev/sda]: " device
device=${device:-/dev/sda}
[[ -b $device ]] || {
	echo "Error: Invalid block device" >&2
	exit 1
}
image=$(find -L result/sd-image -name '*.img' -type f)
[[ -f $image ]] || {
	echo "Error: No image found" >&2
	exit 1
}
sudo dd if="$image" of="$device" bs=4M status=progress oflag=sync

# Wait for device to be mounted.
echo "Remove and reinsert the device, then press Enter."
read -r

# Preconfigure Wi-Fi access.
read -rp "Enter Wi-Fi SSID: " ssid
read -rsp "Enter Wi-Fi PSK: " psk
echo

cd "/run/media/$USER/NIXOS_SD/"
sudo mkdir etc
sudo tee etc/wpa_supplicant.conf <<EOF
network={
  ssid="$ssid"
  psk="$psk"
}
EOF

echo "Done. Insert the SD card into the Pi and power it on."
