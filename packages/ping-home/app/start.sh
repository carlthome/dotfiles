#!/bin/bash
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 2
tailscale up --authkey=${TAILSCALE_AUTH_KEY} --hostname=gcp-health-checker --accept-routes
exec uv run uvicorn --host 0.0.0.0 --port 8080 main:app
