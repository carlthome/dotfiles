# Raspberry Pi with NixOS

## Usage

### Installation

```sh
./install.sh
```

Plug the SD card (or USB drive) into the Raspberry Pi and power it up.

Optionally, add to `~/.ssh/config`:

```
Host pi
  HostName pi.local
  User pi
  ForwardAgent yes
```

Such that you'll be able to `ssh pi` into the machine.

### Test configuration

```sh
# Launch a VM to test that the configuration works as intended.
QEMU_NET_OPTS="hostfwd=tcp::2222-:22" nix run .#nixosConfigurations.pi.config.system.build.vm -- -serial stdio

# Or build a QEMU image for later use.
nixos-rebuild build-vm --flake .#pi
```

### Update configuration

```sh
# Build and switch to the latest configuration on the remote.
ssh pi
nixos-rebuild --flake github:carlthome/dotfiles#pi test

# Or build a local configuration and update the remote.
nixos-rebuild --flake .#pi --target-host pi --use-remote-sudo test

# Or also build remotely (e.g. if the local machine is macOS):
nixos-rebuild --flake .#pi --fast --build-host pi --target-host pi --use-remote-sudo test
```

Replace `test` with `switch` to apply the new configuration on reboot. Note that this can lead to permanent lock out without physical access. To recover, access the SD card on another machine and edit NIXOS_SD/boot/extlinux/extlinux.conf to temporarily boot into the last known working configuration.

## References

- https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
- https://discourse.nixos.org/t/how-to-use-exported-grafana-dashboard/27739/2
- https://frederikstroem.com/journal/bootstrapping-nixos-on-a-headless-raspberry-pi-4
