#!/bin/bash
# install-tailscale-host.sh
#
# Purpose:
#   Install Tailscale on the Proxmox host.
#
# Run location:
#   Run on the Proxmox host.

set -e

curl -fsSL https://tailscale.com/install.sh | sh

echo "Start login process:"
echo "tailscale up --ssh"
