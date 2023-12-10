# Raspberry Pi with NixOS

```sh
# Build OS image.
nix build .#nixosConfigurations.pi.config.system.build.sdImage

# Write image to SD card (or USB drive).
image=result/sd-image/nixos-sd-image-*.img
device=/dev/sdb
sudo dd if=$image of=$device bs=4096 conv=fsync status=progress

# TODO Remote update and switch.
nixos-rebuild --flake . --target-host
```
