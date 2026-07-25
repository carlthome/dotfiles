# ping-home

A Cloud Run service that pings a home LAN endpoint every 5 minutes through a Tailscale tunnel and exposes Prometheus metrics. This is a self-contained example with its own install script, application code, and Terraform configuration.

## Usage

Prerequisites: `gcloud auth login` and `gh auth login`.

1. Run the install script to set up Workload Identity Federation, Google Cloud secrets, and the GitHub Actions environment:

   ```sh
   ./install.sh
   ```

2. Push to the repository to trigger the GitHub Actions deployment workflow.

## Rotate the Tailscale auth key

Tailscale auth keys expire after at most 90 days. When the key expires,
`home-lan-checker` fails to start with an error such as:

```text
backend error: invalid key: API key does not exist
```

Generate a new **reusable, ephemeral** auth key with the `tag:monitor` tag in
the Tailscale admin console. If Tailnet Lock is enabled, sign the key from a
trusted signing node before continuing:

```sh
tailscale lock sign <auth-key>
```

Then add the key as a new version of the existing GCP secret:

```sh
./rotate-tailscale-auth-key.sh
```

The key is entered without echo and is sent directly to Secret Manager. It is
not passed as a command-line argument or stored in the repository. Failed Cloud
Run instances will read the new `latest` secret version when they restart.

## Tailnet Lock

If tailnet lock is enabled, the auth key must be pre-signed so ephemeral containers are automatically trusted. From a trusted signing node (e.g., pi):

```sh
tailscale lock sign <auth-key>
```

This only needs to be done once per auth key. New containers authenticating with the pre-signed key will be automatically signed.
