#!/bin/bash
echo "Updating Pi-hole gravity (blocklists)..."
pihole -g
echo ""
echo "Current stats:"
pihole -c -e
