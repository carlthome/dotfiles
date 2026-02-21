#!/bin/bash
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 2
tailscale up --authkey=${TAILSCALE_AUTH_KEY} --hostname=gcp-health-checker --accept-routes
exec uv run gunicorn --bind :8080 --workers 1 --threads 8 --timeout 0 main:app
