# GitHub Actions runners

`default.nix` runs a self-hosted runner on the Pi for each repository in `githubRunners`. A workflow sends a job there with `runs-on: [self-hosted, Linux, ARM64]`. Workflow routing belongs in each repository; do not add temporary recovery labels or use repository variables to redirect jobs.

## Add a repository

The single runner is managed as `github-actions-runner.service`; NixOS also creates its internal instance unit. Add a line to `githubRunners`, give it a token file (see below), and merge. The Pi currently runs only `actions`: multiple compilers and a system rebuild sharing its memory budget caused days of reclaim thrashing. Jobs queue behind one worker; the old second worker's cache is retained on USB. The Pi picks up cached configurations at its nightly auto-upgrade (04:40), or deploy as described in [the Pi's README](../README.md).

## Protecting DNS and DHCP

The runner, Xvfb, the Nix daemon and automatic upgrades share one `ci.slice` budget: 150% CPU
(1.5 cores), memory reclaim at 40% of RAM, a hard limit at 50%, no swap, and
1024 tasks. Low CPU/I/O weights and idle I/O priority on runners and the daemon
favor normal services under contention. I/O prioritization depends on the device's
scheduler; these limits reduce interference, but do not guarantee DNS latency.

Nix builds one derivation at a time with one core; Cargo, Rust tests, Rayon,
software rendering and OpenMP default to one worker per runner. Workflows can
override worker defaults, but still share the slice limits. System rebuilds also
share this budget. Excessive jobs can fail at the memory or task limit rather
than exhaust the host; CI may take longer.

Nix build scratch goes to `/mnt/cache/nix-build` on USB, alongside the
runner caches. Builds wait for the USB mount; installed Nix store outputs
remain on the SD card. Automatic upgrades are constrained separately because
root's Nix builds can bypass the daemon.

Automatic upgrades pass `--max-jobs 0` and time out after 30 minutes. The
dotfiles workflow builds Pi configurations on a native ARM hosted runner and
publishes them to Cachix. An uncached configuration fails the automatic upgrade
instead of compiling a kernel on the DNS host; updates wait until CI publishes
their closure. Manual rebuilds can still compile locally. The runner restarts
after process failures, with a 30-second delay.

`/mnt/cache` mounts the USB drive's `cache` Btrfs subvolume with `noatime`.
Create that subvolume before activation and set `chattr +C` on its empty root.
New cache files then avoid copy-on-write, checksums and compression. These
files are regenerable and excluded from backups. The inode flag confines this
tuning to caches; Btrfs compression/CoW mount options apply to the whole drive.

Runner registration state and diagnostics also live on USB, at
`/mnt/cache/github-runner-state` and `/mnt/cache/github-runner-logs`, bind-mounted
at the runner's standard `/var/lib` and `/var/log` paths. Diagnostic files expire
after 14 days through systemd's existing tmpfiles cleanup. Only the runners
require these mounts; DNS and the installed system remain available without USB.

After deploying, check `systemctl show ci.slice -p CPUQuotaPerSecUSec -p MemoryHigh
-p MemoryMax -p MemorySwapMax -p TasksMax` (on one line) and `systemd-cgls /ci.slice`.
Check DNS response times from another machine during a busy job; configuration
validation alone cannot establish latency under load.

## Caches

Each runner deletes its work dir whenever its service restarts, so build state lives beside it and survives:

- `/mnt/cache/github-runner/.cache/<instance>` — the build tree (`CARGO_TARGET_DIR`) and any Nix dev shell a workflow records under `CI_CACHE_DIR`. Per instance, because two concurrent cargo builds cannot share a target dir.
- `/mnt/cache/github-runner/.cache/cargo` — downloaded crate sources (`CARGO_HOME`), shared by every instance. Cargo locks it itself, so a lockfile change costs one download for the machine rather than one per instance.

Delete an instance's directory to make it build from scratch; delete the shared one to re-download crates.

During migration, old paths under `/mnt/datasets/.github-runner` are symlinks
to `/mnt/cache/github-runner`. Original directories ending in
`.before-cache-move` retain a rollback copy; existing data was reflinked, so
its blocks are shared. New files inherit the cache's no-CoW flag.

Until the flake is activated, the Pi uses a mount unit and service drop-ins
under `/etc/systemd/system.control` (`mnt-cache.mount`, `usb-cache.conf` and
`usb-builds.conf`, plus runner state/log bind mounts). Remove these migration
overrides and their copies under `/run/systemd/system` after activating this
configuration, then reload systemd.
The temporary `/etc/fail2ban/jail.d/99-pi-ssh-only.local` and
`/etc/tmpfiles.d/pi-runner-diagnostics.conf` can then be removed too.

## Token

Each runner reads a fine-grained personal access token from a root-only file on the Pi, `/etc/nixos/secrets/github-runner/<name>.token`, like the other secrets under `/etc/nixos/secrets`. Nothing secret is stored in this repository.

1. Create the token at <https://github.com/settings/personal-access-tokens/new> with **Repository permissions → Administration: Read and write**, for the repository (or for all repositories, so one token serves every runner).
2. On the Pi, in `bash` (the login shell is fish), install it without echoing it:

   ```sh
   sudo install -d -m 700 /etc/nixos/secrets/github-runner
   read -rs T && printf %s "$T" | sudo tee /etc/nixos/secrets/github-runner/<name>.token >/dev/null
   sudo chmod 600 /etc/nixos/secrets/github-runner/<name>.token
   ```

   To reuse an existing token for a new runner, copy its file to the new name instead.

3. A changed token file re-registers the runner when its service next starts (`sudo systemctl restart github-runner-<name>`). Check with:

   ```sh
   gh api repos/carlthome/rustler/actions/runners --jq '.runners[] | "\(.name) \(.status)"'
   ```

The token can administer every repository it covers, so rotate it if the Pi is compromised.
