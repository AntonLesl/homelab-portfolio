# 04 — Pi-hole + DNS over HTTPS

**Skills:** DNS filtering, Cloudflared DoH, threat blocklists, anomalous domain monitoring

## Deployment
Pi-hole runs as a VM (CT 100) on Proxmox, connected to vmbr0 with VLAN tag 10.
Static IP: `192.168.10.2`

## DNS Chain
```
Client → Pi-hole (192.168.10.2:53) → Cloudflared (127.0.0.1:5053) → Cloudflare 1.1.1.1 (HTTPS)
```

## Key Commands
```bash
# Install Pi-hole
curl -sSL https://install.pi-hole.net | bash

# Install Cloudflared DoH
wget cloudflared-linux-amd64.deb && dpkg -i cloudflared-linux-amd64.deb
# Config: proxy-dns-port 5053 → https://1.1.1.1/dns-query

# Update blocklists
pihole -g
```

## Blocklists
See [blocklists.md](./blocklists.md)

## Resume Bullets
> "Deployed Pi-hole VM with 1.2M+ domain blocklist from OISD, Steven Black, and URLhaus"
> "Configured DNS over HTTPS via Cloudflared eliminating ISP DNS snooping"
