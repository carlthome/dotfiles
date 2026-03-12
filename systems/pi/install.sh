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

# Configure alertmanager secrets.
read -rp "Enter Slack webhook URL (or press Enter to skip): " slack_url
if [[ -n $slack_url ]]; then
	read -rp "Enter Slack channel [#alerts]: " slack_channel
	slack_channel=${slack_channel:-#alerts}
	sudo mkdir -p etc/nixos/secrets
	sudo tee etc/nixos/secrets/alertmanager.env <<-EOF
		SLACK_API_URL=$slack_url
		SLACK_CHANNEL=$slack_channel
	EOF
	sudo chmod 600 etc/nixos/secrets/alertmanager.env
fi

echo "Done. Insert the SD card into the Pi and power it on."
