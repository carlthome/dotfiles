terraform {
  backend "gcs" {
    # Bucket is passed at init time via -backend-config (set as TERRAFORM_STATE_BUCKET_NAME GitHub secret).
    prefix = "terraform/tailscale/state"
  }
  required_providers {
    tailscale = { source = "tailscale/tailscale", version = "~> 0.29" }
  }
}

provider "tailscale" {
  # Uses TAILSCALE_OAUTH_CLIENT_ID and TAILSCALE_AUDIENCE (workload identity federation) in CI,
  # or TAILSCALE_API_KEY when run locally.
}

# The tailnet policy file. This replaces the entire policy, so edit it here rather than in the admin console.
import {
  to = tailscale_acl.policy
  id = "acl"
}

resource "tailscale_acl" "policy" {
  acl = file("${path.module}/policy.hujson")
}
