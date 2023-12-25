# Raspberry Pi with NixOS

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
printf 'network={\n  ssid="My Network"\n  psk="My Password"\n}\n' | sudo tee /run/media/$USER/NIXOS_SD/etc/wpa_supplicant.conf

# Plug the SD card (or USB drive) into the Raspberry Pi and power it up. Then rebuild the configuration remotely as needed by running:
nixos-rebuild --flake .#pi --target-host pi --use-remote-sudo switch
```
