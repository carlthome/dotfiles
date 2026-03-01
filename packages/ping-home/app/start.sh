#!/bin/bash

# Start Tailscale in userspace networking mode with a SOCKS5 server.
tailscaled --tun=userspace-networking --socks5-server="${TS_SOCKS5_SERVER}" 2>&1 | grep -i -E "error|warn|fatal" &
sleep 2

# Authenticate with Tailscale using the provided auth key.
TS_AUTHKEY=$(cat /secrets/tailscale-auth-key)
tailscale up --authkey="${TS_AUTHKEY}" --hostname="${TS_HOSTNAME}" --accept-routes 2>&1 | grep -i -E "error|warn|fatal"

# Start the FastAPI application using Uvicorn.
exec uvicorn --host 0.0.0.0 --port 8080 main:app
