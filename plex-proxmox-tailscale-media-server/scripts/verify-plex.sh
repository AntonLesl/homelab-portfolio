#!/bin/bash
# verify-plex.sh
#
# Purpose:
#   Verify that Plex Media Server is running correctly inside the Plex LXC container.
#
# Run location:
#   Run this script INSIDE the Plex container, not on the Proxmox host.
#
# Privacy note:
#   This script does not include any personal IP addresses, usernames, hostnames, or machine IDs.

# Print a section header so the output is easy to read.
echo "=== Plex Process Check ==="

# Search for running Plex processes.
# This confirms whether Plex Media Server is actually running.
# The second grep removes the grep command itself from the results.
ps -ef | grep -i plex | grep -v grep || echo "No Plex process found."

echo
echo "=== Plex Port Check ==="

# Check whether Plex is listening on its default web/API port: 32400.
# If this shows LISTEN, Plex is accepting local network connections.
ss -tlnp | grep 32400 || echo "Port 32400 is not listening."

echo
echo "=== Plex Local API Test ==="

# Test Plex locally through the loopback interface.
# A successful response should return XML from Plex.
curl -s http://localhost:32400/identity || echo "Plex API did not respond locally."

echo
