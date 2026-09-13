# GitHub Actions runners

`default.nix` runs a self-hosted runner on the Pi for each repository in `githubRunners`. A workflow sends a job there with `runs-on: [self-hosted, <name>-pi]` (rustler picks its runner through its `LINUX_RUNNER` repository variable).

## Add a repository

Add a line to `githubRunners` and merge. The Pi picks it up at its nightly auto-upgrade (04:40), or deploy right away as described in [the Pi's README](../README.md).

## Token (set up once)

All runners share one fine-grained personal access token. It is stored encrypted in `secrets.yaml` and decrypted on the Pi with its SSH host key.

1. Create the token at <https://github.com/settings/personal-access-tokens/new>:
   - Resource owner: your account
   - Repository access: **All repositories**
   - Repository permissions: **Administration → Read and write**
   - Expiration: your choice, but the runners stop registering once it lapses
2. From the repository root, open the secrets file. sops asks for your SSH key's passphrase and opens `$EDITOR`:

   ```sh
   SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_ed25519 sops systems/pi/github-runners/secrets.yaml
   ```

   Replace the placeholder value of `github-runner-token` with the token, save, commit and merge.

3. The next auto-upgrade installs it and re-registers the runners. Check with:

   ```sh
   gh api repos/carlthome/rustler/actions/runners --jq '.runners[] | "\(.name) \(.status)"'
   ```

This token can administer every repository you own, so rotate it if the Pi or one of the machines in `.sops.yaml` is compromised. `.sops.yaml` at the repository root lists who can decrypt it (the Pi's host key, and the mba, mba-2 and t1 SSH keys). After changing that list, run `sops updatekeys systems/pi/github-runners/secrets.yaml`.
