#!/bin/bash
tailscaled --tun=userspace-networking --socks5-server="${TS_SOCKS5_SERVER}" &
sleep 2
tailscale up --authkey="${TS_AUTHKEY}" --hostname="${TS_HOSTNAME}" --accept-routes
exec uv run uvicorn --host 0.0.0.0 --port 8080 main:app
