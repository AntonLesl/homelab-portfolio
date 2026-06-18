#!/bin/bash
# Roll back all cyber lab VMs to a snapshot
# Usage: bash proxmox-rollback.sh "clean-state"
LABEL=${1:-"clean-state"}
for VMID in 200 201 202 203; do
  echo "Rolling back VM $VMID to $LABEL..."
  qm rollback "$VMID" "$LABEL"
done
echo "All VMs rolled back."
