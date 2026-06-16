#!/bin/bash
# install-plex.sh
#
# Purpose:
#   Install Plex Media Server inside an Ubuntu/Debian LXC container.
#
# Run location:
#   Run INSIDE the Plex container.
#
# Privacy:
#   No personal information is stored in this script.

set -e

echo "Updating package lists..."
apt update

echo "Installing dependencies..."
apt install -y curl gnupg apt-transport-https ca-certificates

echo "Adding Plex repository key..."
curl https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor -o /usr/share/keyrings/plex.gpg

echo "Adding Plex repository..."
echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" \
> /etc/apt/sources.list.d/plexmediaserver.list

echo "Installing Plex..."
apt update
apt install -y plexmediaserver

echo "Checking service status..."
systemctl status plexmediaserver --no-pager || true

echo "Installation complete."
