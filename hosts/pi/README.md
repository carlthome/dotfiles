# Raspberry Pi with NixOS

## Usage

```sh
# Build OS image.
nix build .#nixosConfigurations.pi.config.system.build.sdImage
image=$(find result/sd-image -type f -name "*.img")

# Look up USB drive device name manually.
lsblk
device=/dev/sdb

# Write image to device.
sudo dd if=$image of=$device bs=4096 conv=fsync status=progress

# Preconfigure Wi-Fi access.
sudo mkdir -p /run/media/$USER/NIXOS_SD/etc/
printf 'network={\n  ssid="My Network"\n  psk="My Password"\n}\n' | sudo tee /run/media/$USER/NIXOS_SD/etc/wpa_supplicant.conf

# Plug the SD card (or USB drive) into the Raspberry Pi and power it up. Then rebuild the configuration remotely as needed by running:
nixos-rebuild --flake .#pi --target-host pi --use-remote-sudo test

# Or build on the remote device (e.g. if the local machine is macOS):
nixos-rebuild --flake .#pi --fast --build-host pi --target-host pi --use-remote-sudo test
```

Replace `test` with `switch` to apply the new configuration on reboot. Note that this can lead to permanent lock out without physical access. To recover, access the SD card on another machine and edit NIXOS_SD/boot/extlinux/extlinux.conf to temporarily boot into the last known working configuration.

## References

- https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
- https://discourse.nixos.org/t/how-to-use-exported-grafana-dashboard/27739/2
