#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-./config/tailscale-proxmox.env}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

echo "Checking macOS client access to Proxmox over Tailscale..."

echo
if command -v tailscale >/dev/null 2>&1; then
  echo "Tailscale CLI found. Status:"
  tailscale status || true
else
  echo "Tailscale CLI not found. Install/open the macOS Tailscale app from: https://tailscale.com/download"
fi

echo
printf 'Testing TCP port %s on %s...\n' "$PVE_WEB_PORT" "$PVE_TAILSCALE_IP"
if command -v nc >/dev/null 2>&1; then
  nc -vz "$PVE_TAILSCALE_IP" "$PVE_WEB_PORT" || true
else
  echo "nc not found; skipping TCP test."
fi

echo
printf 'Testing HTTPS endpoint by IP...\n'
curl -k --connect-timeout 10 -I "https://${PVE_TAILSCALE_IP}:${PVE_WEB_PORT}" || true

echo
printf 'Testing MagicDNS name...\n'
curl -k --connect-timeout 10 -I "https://${PVE_MAGICDNS_NAME}:${PVE_WEB_PORT}" || true

echo
cat <<MSG
Expected browser URL:
  https://${PVE_TAILSCALE_IP}:${PVE_WEB_PORT}
  https://${PVE_MAGICDNS_NAME}:${PVE_WEB_PORT}

If the IP works but MagicDNS fails, enable MagicDNS and Tailscale DNS in the admin console and reconnect the macOS app.
MSG
