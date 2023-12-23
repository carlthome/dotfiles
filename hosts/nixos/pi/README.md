# Raspberry Pi with NixOS

```sh
# Preconfigure Wi-Fi access.
echo '{ networking.wireless.networks."My Network".psk = "My Password"; }' > hosts/nixos/pi/wifi.nix

# Build OS image.
nix build .#nixosConfigurations.pi.config.system.build.sdImage
image=$(find result/sd-image -type f -name "*.img")

# Look up USB drive device name manually.
lsblk
device=/dev/sdb

# Write image to device.
sudo dd if=$image of=$device bs=4096 conv=fsync status=progress

# Plug the SD card (or USB drive) into the Raspberry Pi and power it up. Then rebuild the configuration remotely as needed by running:
nixos-rebuild --flake .#pi --target-host pi --use-remote-sudo switch
```
