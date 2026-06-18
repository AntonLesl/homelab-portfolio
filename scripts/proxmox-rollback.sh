#!/bin/bash
# Roll back all cyber lab VMs to a snapshot
# Usage: bash proxmox-rollback.sh "clean-state"

LABEL=${1:-"clean-state"}
VMIDS=(200 201 202 203)

echo "Rolling back lab VMs to: $LABEL"
for VMID in "${VMIDS[@]}"; do
  echo "  Rolling back VM $VMID..."
  qm rollback "$VMID" "$LABEL"
done
echo "Done."
