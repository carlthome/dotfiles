#!/bin/bash
set -euo pipefail

# Start Tailscale in userspace networking mode with a SOCKS5 server.
tailscaled --tun=userspace-networking --state=mem: --socks5-server="${TS_SOCKS5_SERVER}" 2>&1 | grep -i -E "error|warn|fatal" &
sleep 2

# Append Cloud Run revision to hostname.
if [ -n "${K_REVISION:-}" ]; then
	TS_HOSTNAME="${TS_HOSTNAME}-${K_REVISION}"
fi

# Authenticate to Tailscale network with the provided auth key.
auth_key_file=${TS_AUTHKEY_FILE:-/secrets/tailscale-auth-key}
if [ ! -s "${auth_key_file}" ]; then
	echo "ERROR: Tailscale auth key secret is missing or empty." >&2
	exit 1
fi

TS_AUTHKEY=$(<"${auth_key_file}")
if ! tailscale_output=$(
	tailscale up \
		--authkey="${TS_AUTHKEY}" \
		--hostname="${TS_HOSTNAME}" \
		--advertise-tags=tag:monitor 2>&1
); then
	echo "ERROR: Tailscale authentication failed. The tailscale-auth-key secret may be expired or revoked." >&2
	printf '%s\n' "${tailscale_output}" >&2
	exit 1
fi
unset TS_AUTHKEY

# Verify we got an IP.
tailscale ip -4 || exit 1

# Wait for SOCKS5 proxy to actually reach the home endpoint.
echo "Waiting for Tailscale connectivity..."
for i in {1..30}; do
	if curl -x "socks5h://${TS_SOCKS5_SERVER}" -s --max-time 3 "${HOME_LAN_ENDPOINT}" >/dev/null 2>&1; then
		echo "Tailscale connection established"
		break
	fi
	echo "Attempt $i: waiting for tunnel..."
	sleep 1
done

# Start the FastAPI application using Uvicorn.
exec uvicorn --host 0.0.0.0 --port 8080 main:app
