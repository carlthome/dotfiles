# GitHub Actions runners

`default.nix` runs a self-hosted runner on the Pi for each repository in `githubRunners`. A workflow sends a job there with `runs-on: [self-hosted, <name>-pi]` (rustler picks its runner through its `LINUX_RUNNER` repository variable).

## Add a repository

Add a line to `githubRunners`, give it a token file (see below), and merge. Several entries may point at one repository (`rustler-1`, `rustler-2`): they share its label and token, so a short job runs beside a long one instead of queueing behind it. Each instance keeps its own work and cache dirs, because concurrent cargo builds cannot share a target dir. The Pi picks it up at its nightly auto-upgrade (04:40), or deploy right away as described in [the Pi's README](../README.md).

## Caches

Each runner deletes its work dir whenever its service restarts, so build state lives beside it and survives:

- `/mnt/datasets/.github-runner/.cache/<instance>` — the build tree (`CARGO_TARGET_DIR`) and any Nix dev shell a workflow records under `CI_CACHE_DIR`. Per instance, because two concurrent cargo builds cannot share a target dir.
- `/mnt/datasets/.github-runner/.cache/cargo` — downloaded crate sources (`CARGO_HOME`), shared by every instance. Cargo locks it itself, so a lockfile change costs one download for the machine rather than one per instance.

Delete an instance's directory to make it build from scratch; delete the shared one to re-download crates.

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
