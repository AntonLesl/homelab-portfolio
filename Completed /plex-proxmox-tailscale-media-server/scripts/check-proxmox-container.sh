#!/bin/bash
# check-proxmox-container.sh
#
# Purpose:
#   Display Proxmox LXC container information and configuration.
#
# Why this matters:
#   Plex may be running inside an LXC container rather than directly on the host.
#   Checking the container config helps confirm network bridge, IP mode, and features.
#
# Run location:
#   Run this script on the Proxmox host.
#
# Privacy note:
#   Container config output may include MAC addresses, local storage names, or device paths.
#   Review output before publishing screenshots or logs.

# Use the first command-line argument as the container ID.
# If none is provided, use a generic default of 100.
CTID="${1:-100}"

echo "=== Proxmox LXC List ==="

# List all LXC containers on the Proxmox host.
# This helps identify the Plex container ID.
pct list

echo
echo "=== Config for CTID $CTID ==="

# Show the configuration for the selected container.
# This helps verify bridge networking, DHCP/static IP, nesting, and other settings.
pct config "$CTID"

echo
echo "=== Next Step ==="

# Print the command needed to enter the container.
echo "To enter this container, run:"
echo "pct enter $CTID"
