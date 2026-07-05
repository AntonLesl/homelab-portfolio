# 08 — Homepage Dashboard

**Status:** ✅ Complete
**Skills:** Self-hosted service deployment, YAML configuration, reverse-proxy awareness

## What This Is

A self-hosted Homepage dashboard that gives a single pane of glass over every service in the homelab — quick links and status tiles for pfSense, Proxmox, Pi-hole, Wazuh, and OpenVAS.

## Why a Dashboard

Once a homelab grows past a handful of services, remembering every URL and port is a chore. A dashboard centralizes access and shows service health at a glance. Homepage is lightweight, YAML-configured, and version-controllable.

## Design

- Homepage deployed as a container on Proxmox
- Service tiles configured in YAML
- Tiles point at the stable Tailscale addresses of pfSense and Proxmox so links work from any network, not just the LAN

## References

- Homepage docs: https://gethomepage.dev/
- Homepage configuration: https://gethomepage.dev/configs/services/
