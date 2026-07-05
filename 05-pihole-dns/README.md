# 05 — Pi-hole + Unbound Recursive DNS

**Status:** ✅ Complete
**Skills:** Network-wide DNS filtering, recursive DNS resolution, LXC deployment

## What This Is

Pi-hole running in an LXC container on Proxmox, providing network-wide ad/tracker blocking, backed by Unbound as a local recursive resolver.

## Why Pi-hole + Unbound

Pi-hole gives every device DNS-level filtering without per-device config. Pairing it with Unbound means DNS queries are resolved recursively from the root servers instead of being forwarded to a third-party resolver — better privacy, and no dependence on an upstream provider. This replaced an earlier cloudflared (DNS-over-HTTPS) plan after cloudflared support was dropped in Pi-hole 2026.2.0.

## Design

- Pi-hole LXC on the services bridge
- Unbound installed alongside as the recursive upstream
- Pi-hole set as the DNS server handed out by pfSense DHCP
- Cross-VLAN DNS enabled via an outbound NAT rule on pfSense (see pfSense section)

## References

- Pi-hole docs: https://docs.pi-hole.net/
- Unbound as recursive resolver (official guide): https://docs.pi-hole.net/guides/dns/unbound/
