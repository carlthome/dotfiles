#!/bin/sh
set -x

lsof -Pn -i4 | grep LISTEN

sudo arp-scan -l

nmap -T5 '192.168.0.*'
