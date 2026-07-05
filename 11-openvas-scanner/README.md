# 11 — OpenVAS / Greenbone Vulnerability Scanner

**Status:** ✅ Complete
**Skills:** Vulnerability management, CVE scanning, Docker-in-LXC, container privileges

## What This Is

Greenbone Community Edition (OpenVAS) deployed as a Docker-based stack inside a privileged LXC container on Proxmox, providing automated vulnerability scanning across the homelab — identifying CVEs and misconfigurations on the production services.

## Why OpenVAS

Vulnerability scanning is core security-operations work. Greenbone/OpenVAS is the leading open-source scanner, shipping a large, regularly-updated feed of network vulnerability tests. Running it against my own infrastructure turns the lab into a continuous self-assessment and produces findings I can prioritize and remediate — the same loop a real vuln-management program runs.

## Deployment

- Greenbone Community Edition via the official Docker Compose stack
- Runs inside a **privileged** LXC (Docker overlay filesystem needs it), with nesting/keyctl/fuse enabled and an unconfined AppArmor profile
- Disk expanded to fit the feed and Docker images (they're large)
- Scan targets configured for the production service hosts

## References

- Greenbone Community Edition (Docker): https://greenbone.github.io/docs/latest/22.4/container/index.html
- Proxmox LXC + Docker considerations: https://pve.proxmox.com/wiki/Linux_Container
