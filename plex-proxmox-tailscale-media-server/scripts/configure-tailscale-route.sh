#!/bin/bash
# configure-tailscale-route.sh
#
# Purpose:
#   Advertise a local LAN subnet through Tailscale so remote Tailscale devices
#   can access services running on the LAN, such as Plex inside an LXC container.
#
# Why this matters:
#   Plex runs inside a container on a LAN IP, while Tailscale runs on the Proxmox host.
#   Subnet routing allows remote devices to reach the Plex container through the host.
#
# Run location:
#   Run this script on the Proxmox host where Tailscale is installed.
#
# Privacy note:
#   Replace the example subnet below with your own LAN subnet before using.
#   Do not commit real private network details if you want the repo fully sanitized.

# Exit immediately if a command fails.
set -e

# Example LAN subnet.
# Replace this with your own LAN subnet if different.
# Example formats:
#   192.168.1.0/24
#   10.0.0.0/24
#   172.16.0.0/24
LAN_SUBNET="${LAN_SUBNET:-192.168.1.0/24}"

echo "=== Advertising LAN subnet through Tailscale ==="
echo "Subnet being advertised: $LAN_SUBNET"

# Enable subnet routing in Tailscale.
# --reset clears previous non-default settings before applying this configuration.
# --advertise-routes tells Tailscale which LAN subnet should be reachable.
# --ssh preserves Tailscale SSH if it was previously enabled.
tailscale up --reset --advertise-routes="$LAN_SUBNET" --ssh

echo
echo "=== Manual Step Required ==="

# Tailscale requires advertised subnet routes to be approved in the admin console.
# This prevents accidental exposure of private networks.
echo "Approve the advertised subnet route in the Tailscale admin console:"
echo "https://login.tailscale.com/admin/machines"
