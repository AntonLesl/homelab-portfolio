#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-./tailscale-proxmox.conf}"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

echo "==> macOS client checks"

if ! command -v tailscale >/dev/null 2>&1; then
  cat <<MSG
ERROR: tailscale CLI not found.
Install the macOS Tailscale app from:
  https://tailscale.com/download

Then open the Tailscale app, log in, and connect to the same tailnet as Proxmox.
MSG
  exit 1
fi

echo "==> Tailscale status"
tailscale status || true

echo

echo "==> Tailscale ping Proxmox"
tailscale ping "${PVE_TAILSCALE_IP}" || true

echo

echo "==> TCP test to Proxmox UI"
if command -v nc >/dev/null 2>&1; then
  nc -vz -w 5 "${PVE_TAILSCALE_IP}" "${PVE_WEB_PORT}" || true
else
  echo "nc not found; skipping TCP test"
fi

echo

echo "==> HTTPS test to Proxmox UI by IP"
curl -4 -vk --connect-timeout 10 "https://${PVE_TAILSCALE_IP}:${PVE_WEB_PORT}" >/dev/null || true

echo

echo "==> DNS test for MagicDNS hostname"
if dscacheutil -q host -a name "${PVE_MAGICDNS}"; then
  echo "OK: MagicDNS resolved"
else
  echo "WARN: MagicDNS did not resolve. Make sure MagicDNS and Tailscale DNS are enabled."
fi

echo
cat <<MSG
Open this in your browser:
  https://${PVE_TAILSCALE_IP}:${PVE_WEB_PORT}

If DNS works:
  https://${PVE_MAGICDNS}:${PVE_WEB_PORT}
MSG
