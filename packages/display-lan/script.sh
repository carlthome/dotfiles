#!/bin/sh
set -x

netstat --tcp --udp --listening --program --numeric | grep LISTEN

sudo arp-scan -l

nmap -sn 192.168.0.*
