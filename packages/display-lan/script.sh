#!/bin/sh
set -x

# List open ports on the current system.
lsof -Pn -i4 | grep LISTEN

# Look up the default network interface.
if [ "$(uname)" = "Darwin" ]; then
	interface=$(route -n get default | grep interface | awk '{print $2}')
	ip_range=$(ifconfig "$interface" | grep 'inet ' | awk '{print $2"/24"}')
else
	interface=$(ip route | grep default | awk '{print $5}')
	ip_range=$(ip -o -f inet addr show "$interface" | awk '{print $4}')
fi

# Find devices on the network with arp-scan.
sudo arp-scan -l -I "$interface"

# Scan the network for open ports with nmap.
nmap -T5 "$ip_range"
