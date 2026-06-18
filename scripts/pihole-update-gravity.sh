#!/bin/bash
# Update Pi-hole blocklists and report stats
echo "Updating Pi-hole gravity..."
pihole -g
echo ""
echo "Pi-hole stats:"
pihole -c -e
