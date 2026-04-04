# ping-home

A Cloud Run service that pings a home LAN endpoint every 5 minutes through a Tailscale tunnel and exposes Prometheus metrics. This is a self-contained example with its own install script, application code, and Terraform configuration.

## Usage

Prerequisites: `gcloud auth login` and `gh auth login`.

1. Run the install script to set up Workload Identity Federation, Google Cloud secrets, and the GitHub Actions environment:

   ```sh
   ./install.sh
   ```

2. Push to the repository to trigger the GitHub Actions deployment workflow.

## Tailnet Lock

If tailnet lock is enabled, the auth key must be pre-signed so ephemeral containers are automatically trusted. From a trusted signing node (e.g., pi):

```sh
tailscale lock sign <auth-key>
```

This only needs to be done once per auth key. New containers authenticating with the pre-signed key will be automatically signed.
