# tailscale

The tailnet policy file, applied with Terraform by the `tailscale` GitHub
Actions workflow on push to `main`. Terraform replaces the whole policy on
apply, so edit `policy.hujson` here rather than in the admin console. The
policy's `tests` run before every update.

## Setup

GitHub Actions authenticates with workload identity federation, so no Tailscale
secret is stored. Create a federated identity once under **Settings → Trust
credentials** with issuer `https://token.actions.githubusercontent.com`, subject
`repo:<owner>/<repo>:environment:production`, and only the `policy_file` scope.
Then store its client ID and generated audience:

```sh
gh variable set TAILSCALE_OAUTH_CLIENT_ID
gh variable set TAILSCALE_AUDIENCE
```

Terraform state lives in the same GCS bucket as `packages/ping-home`, under its
own prefix, and the workflow reuses that package's GCP credentials to reach it.

To run Terraform locally, set `TAILSCALE_API_KEY`:

```sh
terraform init -backend-config="bucket=$TERRAFORM_STATE_BUCKET_NAME"
TAILSCALE_API_KEY=… terraform plan
```
