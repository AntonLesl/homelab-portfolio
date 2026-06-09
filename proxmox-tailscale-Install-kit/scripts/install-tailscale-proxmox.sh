#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-./config/tailscale-proxmox.env}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root on the Proxmox host." >&2
  exit 1
fi

echo "Installing Tailscale on Proxmox host: ${PVE_HOSTNAME}"

if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | sh
else
  echo "Tailscale already installed."
fi

systemctl enable --now tailscaled

UP_FLAGS=(--hostname="$PVE_HOSTNAME")

if [[ "${TS_ACCEPT_DNS}" == "true" ]]; then
  UP_FLAGS+=(--accept-dns=true)
else
  UP_FLAGS+=(--accept-dns=false)
fi

if [[ "${TS_ENABLE_SSH}" == "true" ]]; then
  UP_FLAGS+=(--ssh)
fi

if [[ "${TS_SHIELDS_UP}" == "true" ]]; then
  UP_FLAGS+=(--shields-up)
fi

if [[ -n "${TS_ADVERTISE_ROUTES}" ]]; then
  UP_FLAGS+=(--advertise-routes="${TS_ADVERTISE_ROUTES}")
  echo "NOTE: approve advertised routes in the Tailscale admin console."
fi

# --reset avoids Tailscale refusing to change settings because previous flags were not restated.
tailscale up --reset "${UP_FLAGS[@]}"

echo
printf 'Tailscale IPv4: '
tailscale ip -4 || true

echo
systemctl status pveproxy --no-pager || true
ss -tlnp | grep ':8006' || true

echo
cat <<MSG
Done.
Open Proxmox from a Tailscale-connected client:
  https://${PVE_TAILSCALE_IP}:${PVE_WEB_PORT}
  https://${PVE_MAGICDNS_NAME}:${PVE_WEB_PORT}
MSG
