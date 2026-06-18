#!/bin/bash
# Snapshot all cyber lab VMs before an exercise
# Usage: bash proxmox-snapshot.sh "pre-kerberoasting"
LABEL=${1:-"clean-state"}
for VMID in 200 201 202 203; do
  echo "Snapshotting VM $VMID as $LABEL..."
  qm snapshot "$VMID" "$LABEL" --description "Before lab: $LABEL"
done
echo "All snapshots done."
