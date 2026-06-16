#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-./tailscale-proxmox.conf}"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root on the Proxmox host."
  exit 1
fi

echo "==> Installing prerequisites"
apt-get update
apt-get install -y curl ca-certificates gnupg lsb-release

if ! command -v tailscale >/dev/null 2>&1; then
  echo "==> Installing Tailscale"
  curl -fsSL https://tailscale.com/install.sh | sh
else
  echo "==> Tailscale already installed"
fi

echo "==> Enabling tailscaled"
systemctl enable --now tailscaled

UP_FLAGS=()

if [[ "${ENABLE_TAILSCALE_SSH}" == "true" ]]; then
  UP_FLAGS+=(--ssh)
fi

if [[ "${ADVERTISE_EXIT_NODE}" == "true" ]]; then
  UP_FLAGS+=(--advertise-exit-node)
fi

if [[ -n "${LAN_ROUTES}" ]]; then
  UP_FLAGS+=(--advertise-routes="${LAN_ROUTES}")
fi

# Important: if changing settings later, use --reset so omitted flags do not cause Tailscale's settings warning.
echo "==> Bringing Tailscale up"
if [[ ${#UP_FLAGS[@]} -gt 0 ]]; then
  tailscale up --reset "${UP_FLAGS[@]}"
else
  tailscale up
fi

echo "==> Checking Proxmox web service"
systemctl enable --now pveproxy
systemctl restart pveproxy

if ss -tlnp | grep -q ':8006'; then
  echo "OK: pveproxy is listening on port 8006"
else
  echo "ERROR: pveproxy does not appear to be listening on port 8006"
  systemctl status pveproxy --no-pager || true
  exit 1
fi

echo "==> Local Proxmox UI test"
if curl -kfsS "https://127.0.0.1:${PVE_WEB_PORT}" >/dev/null; then
  echo "OK: local Proxmox UI responds"
else
  echo "ERROR: local Proxmox UI test failed"
  exit 1
fi

echo
actual_ip="$(tailscale ip -4 | head -n1 || true)"
echo "Tailscale IPv4: ${actual_ip}"
echo "Expected IPv4:  ${PVE_TAILSCALE_IP}"
echo
cat <<MSG
Done.

From a Tailscale-connected client, open:
  https://${PVE_TAILSCALE_IP}:${PVE_WEB_PORT}

If MagicDNS is enabled on the client, also try:
  https://${PVE_MAGICDNS}:${PVE_WEB_PORT}
MSG
