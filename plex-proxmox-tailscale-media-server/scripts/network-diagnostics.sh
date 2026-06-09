#!/bin/bash
# network-diagnostics.sh
#
# Purpose:
#   Collect basic network troubleshooting information from either the Proxmox host
#   or the Plex container.
#
# Why this matters:
#   This helps identify whether a problem is related to IP addressing, routing,
#   listening ports, or IP forwarding.
#
# Run location:
#   Can be run on the Proxmox host or inside the Plex LXC container.
#
# Privacy note:
#   Output may include private IP addresses. Review before posting publicly.

echo "=== Hostname ==="

# Show the current system hostname.
# This helps confirm whether commands are being run on the host or inside the container.
hostname

echo
echo "=== IP Addresses ==="

# Show all IP addresses assigned to this system.
# Useful for identifying LAN, VPN, and container addresses.
hostname -I

echo
echo "=== Interfaces ==="

# Show detailed network interface information.
# Look for interfaces such as eth0, vmbr0, or tailscale0.
ip a

echo
echo "=== Routes ==="

# Show the routing table.
# This helps confirm how traffic leaves the system.
ip route

echo
echo "=== IPv4 Forwarding ==="

# Show whether IPv4 forwarding is enabled.
# Required for subnet routing on the Proxmox host.
sysctl net.ipv4.ip_forward 2>/dev/null || echo "Unable to read IPv4 forwarding setting."

echo
echo "=== Listening TCP Ports ==="

# Show services listening for TCP connections.
# Useful for confirming whether Plex is listening on port 32400.
ss -tlnp

echo
echo "=== Plex Port Check ==="

# Specifically check for Plex default port 32400.
# If no result appears, Plex may not be running on this system.
ss -tlnp | grep 32400 || echo "Plex port 32400 not found on this machine."
