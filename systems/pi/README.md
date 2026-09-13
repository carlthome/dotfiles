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

### Tailscale DNS

To access `grafana.home`, `jellyfin.home`, etc. via Tailscale:

1. Get the Pi's Tailscale IP: `ssh pi tailscale ip -4`
2. Go to [Tailscale DNS settings](https://login.tailscale.com/admin/dns)
3. Click "Add nameserver" → "Custom" → enter the Pi's IP → restrict to `home`
4. Go to [Machines](https://login.tailscale.com/admin/machines) → Pi → approve the `192.168.0.0/24` route

Done. All devices on your tailnet can now access `*.home` domains.

## GitHub Actions runners

`github-runners.nix` runs a self-hosted runner for each repository in `githubRunners`. A workflow sends a job there with `runs-on: [self-hosted, <name>-pi]` (rustler picks its runner through its `LINUX_RUNNER` repository variable).

### Add a repository

Add a line to `githubRunners` and merge. The Pi picks it up at its nightly auto-upgrade (04:40), or deploy right away with one of the commands above.

### Token (set up once)

All runners share one fine-grained personal access token. It is stored encrypted in `secrets.yaml` and decrypted on the Pi with its SSH host key.

1. Create the token at <https://github.com/settings/personal-access-tokens/new>:
   - Resource owner: your account
   - Repository access: **All repositories**
   - Repository permissions: **Administration → Read and write**
   - Expiration: your choice, but the runners stop registering once it lapses
2. From the repository root, open the secrets file. sops asks for your SSH key's passphrase and opens `$EDITOR`:

   ```sh
   SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_ed25519 sops systems/pi/secrets.yaml
   ```

   Replace the placeholder value of `github-runner-token` with the token, save, commit and merge.

3. The next auto-upgrade installs it and re-registers the runners. Check with:

   ```sh
   gh api repos/carlthome/rustler/actions/runners --jq '.runners[] | "\(.name) \(.status)"'
   ```

This token can administer every repository you own, so rotate it if the Pi or one of the machines in `.sops.yaml` is compromised. `.sops.yaml` at the repository root lists who can decrypt it (the Pi's host key, and the mba, mba-2 and t1 SSH keys). After changing that list, run `sops updatekeys systems/pi/secrets.yaml`.

## References

- https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
- https://discourse.nixos.org/t/how-to-use-exported-grafana-dashboard/27739/2
- https://frederikstroem.com/journal/bootstrapping-nixos-on-a-headless-raspberry-pi-4
