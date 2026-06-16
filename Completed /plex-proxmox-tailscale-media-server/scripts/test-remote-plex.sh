#!/bin/bash
# test-remote-plex.sh
#
# Purpose:
#   Test remote access to Plex from a client machine, such as a laptop.
#
# Why this matters:
#   After Tailscale subnet routing is configured, remote devices should access Plex
#   through the Plex container's LAN IP, not the Proxmox host's Tailscale IP.
#
# Run location:
#   Run this from a client device connected to Tailscale.
#
# Privacy note:
#   Do not hard-code your real Plex IP in this script.
#   Pass the IP as a command-line argument instead.

# Store the first command-line argument as the Plex IP address.
PLEX_IP="$1"

# If no IP address was provided, show usage instructions and exit.
if [ -z "$PLEX_IP" ]; then
  echo "Usage: $0 <plex-lan-ip>"
  echo "Example: $0 192.168.x.x"
  exit 1
fi

echo "=== Testing Plex at $PLEX_IP ==="

# Test the Plex identity endpoint.
# A successful response should return XML from Plex.
curl -v "http://$PLEX_IP:32400/identity"
