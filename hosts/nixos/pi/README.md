# Raspberry Pi with NixOS

```sh
# Preconfigure Wi-Fi access.
echo '{ networking.wireless.networks."My Network".psk = "My Password"; }' > hosts/nixos/pi/wifi.nix

# Build OS image.
nix build .#nixosConfigurations.pi.config.system.build.sdImage

# Write image to SD card (or USB drive).
image=result/sd-image/nixos-sd-image-*.img
device=/dev/sdb
sudo dd if=$image of=$device bs=4096 conv=fsync status=progress

# TODO Remote update and switch.
nixos-rebuild --flake . --target-host
```
