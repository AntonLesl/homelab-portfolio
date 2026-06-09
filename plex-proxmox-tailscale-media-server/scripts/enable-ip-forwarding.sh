#!/bin/bash
# enable-ip-forwarding.sh
#
# Purpose:
#   Enable IPv4 forwarding on the Proxmox host.
#
# Why this matters:
#   Tailscale subnet routing requires the host to forward packets between
#   the Tailscale interface and the local LAN bridge.
#
# Run location:
#   Run this script on the Proxmox host, not inside the Plex container.
#
# Privacy note:
#   This script uses generic system settings only and contains no personal information.

# Exit immediately if a command fails.
# This prevents the script from continuing after a failed configuration step.
set -e

echo "=== Enabling IPv4 forwarding immediately ==="

# Enable IPv4 forwarding for the current running session.
# This takes effect immediately but does not survive reboot by itself.
sysctl -w net.ipv4.ip_forward=1

echo
echo "=== Making IPv4 forwarding permanent ==="

# Add the setting to /etc/sysctl.conf only if it is not already present.
# This makes the setting persist after reboot.
if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

# Reload sysctl settings from /etc/sysctl.conf.
# This verifies that the permanent configuration is valid.
sysctl -p

echo
echo "=== Verification ==="

# Display the current IPv4 forwarding value.
# Expected result: net.ipv4.ip_forward = 1
sysctl net.ipv4.ip_forward
