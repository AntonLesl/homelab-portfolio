#!/usr/bin/env bash
set -euo pipefail

# Temporary runtime firewall allowance for testing.
# This does NOT permanently configure Proxmox firewall GUI rules.
# Use this only if pve-firewall or host firewall blocks Tailscale traffic.

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root on Proxmox."
  exit 1
fi

echo "Allowing Tailscale interface traffic to Proxmox web UI port 8006 via iptables..."
iptables -I INPUT -i tailscale0 -p tcp --dport 8006 -j ACCEPT
iptables -I INPUT -i tailscale0 -p tcp --dport 22 -j ACCEPT

echo "Rules added. Test from client: https://100.112.238.38:8006"
echo "To remove after reboot, no action needed. For permanent config, add equivalent Proxmox firewall rules."
