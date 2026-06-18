#!/bin/bash
# Snapshot all cyber lab VMs before an exercise
# Usage: bash proxmox-snapshot.sh "pre-kerberoasting"

LABEL=${1:-"clean-state"}
VMIDS=(200 201 202 203)

echo "Snapshotting lab VMs with label: $LABEL"
for VMID in "${VMIDS[@]}"; do
  echo "  Snapshotting VM $VMID..."
  qm snapshot "$VMID" "$LABEL" --description "Snapshot before lab: $LABEL"
done
echo "Done."
