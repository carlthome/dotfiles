#!/bin/sh
set -x

# List open ports on the current system.
lsof -Pn -i4 | grep LISTEN

# Find devices on the network with arp-scan.
interface=$(ip route | grep default | awk '{print $5}')
sudo arp-scan -l -I "$interface"

# Scan the network for open ports with nmap.
ip_range=$(ip -o -f inet addr show "$interface" | awk '{print $4}')
nmap -T5 "$ip_range"
