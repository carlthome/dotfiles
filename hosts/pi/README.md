# Raspberry Pi with NixOS

## Usage

### Installation

```sh
# Build OS image.
nix build .#nixosConfigurations.pi.config.system.build.sdImage --print-build-logs

# You can also launch a VM to test that the configuration works as intended.
nix run .#nixosConfigurations.pi.config.system.build.vm -- -serial stdio

# Or build a QEMU image for later use.
nixos-rebuild build-vm --flake .#pi

# Look up USB drive device name manually.
lsblk
device=/dev/sda

# Write image to device.
image=$(find result/sd-image -type f -name "*.img")
sudo dd if=$image of=$device bs=4M status=progress oflag=sync

# Preconfigure Wi-Fi access.
sudo mkdir -p /run/media/$USER/NIXOS_SD1/etc/
printf 'network={\n  ssid="My Network"\n  psk="My Password"\n}\n' | sudo tee /run/media/$USER/NIXOS_SD1/etc/wpa_supplicant.conf

# Update local SSH configuration.
printf '\nHost pi\n  HostName pi.local\n  ForwardAgent yes\n' | tee --append ~/.ssh/config

```

Plug the SD card (or USB drive) into the Raspberry Pi and power it up. You should be able to `ssh pi` into the machine.

### Update configuration

```sh
# Build and switch to the latest configuration on the remote.
ssh pi
nixos-rebuild --flake github:carlthome/dotfiles#pi test

# Or build a local configuration on another system and update remotely.
nixos-rebuild --flake .#pi --target-host pi --use-remote-sudo test

# Or also build on the remote (e.g. if the local machine is macOS):
nixos-rebuild --flake .#pi --fast --build-host pi --target-host pi --use-remote-sudo test
```

Replace `test` with `switch` to apply the new configuration on reboot. Note that this can lead to permanent lock out without physical access. To recover, access the SD card on another machine and edit NIXOS_SD/boot/extlinux/extlinux.conf to temporarily boot into the last known working configuration.

## References

- https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
- https://discourse.nixos.org/t/how-to-use-exported-grafana-dashboard/27739/2
