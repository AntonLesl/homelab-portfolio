# 06 — Tailscale Mesh VPN

**Status:** ✅ Complete
**Skills:** Zero-trust mesh VPN, subnet routing, WireGuard, ACL policy

## What This Is

A Tailscale mesh VPN overlaying pfSense and Proxmox, giving secure remote access to the homelab from anywhere — with zero open ports on the WAN.

## Why Tailscale

Traditional remote access means port-forwarding and exposing services to the internet. Tailscale (built on WireGuard) creates an encrypted mesh where devices connect to each other directly through a coordination plane, so nothing needs to be exposed on the WAN. Subnet routing lets a single node advertise a whole LAN/VLAN so I can reach internal services without installing Tailscale on every device.

## Design

- Tailscale on Proxmox acting as a subnet router advertising the internal subnet(s)
- Tailscale on pfSense for firewall-level remote management
- ACL policy restricting who can reach which subnets
- Dashboard tiles use the stable Tailscale addresses so they resolve from any network

## References

- Tailscale subnet routers: https://tailscale.com/kb/1019/subnets/
- Tailscale ACLs: https://tailscale.com/kb/1018/acls/
- Tailscale on pfSense: https://tailscale.com/kb/1097/install-freebsd/
