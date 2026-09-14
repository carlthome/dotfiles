# GitHub Actions runners

`default.nix` runs a self-hosted runner on the Pi for each repository in `githubRunners`. A workflow sends a job there with `runs-on: [self-hosted, <name>-pi]` (rustler picks its runner through its `LINUX_RUNNER` repository variable).

## Add a repository

Add a line to `githubRunners`, give it a token file (see below), and merge. The Pi picks it up at its nightly auto-upgrade (04:40), or deploy right away as described in [the Pi's README](../README.md).

## Caches

Each runner deletes its work dir whenever its service restarts, so build state lives next to it in `/mnt/datasets/.github-runner/.cache/<name>`: cargo's registry (`CARGO_HOME`) and target dir (`CARGO_TARGET_DIR`), plus any Nix dev shell a workflow records under `CI_CACHE_DIR` to protect it from garbage collection. Delete that directory to start a runner from scratch.

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
