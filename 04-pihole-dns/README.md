# 04 — Pi-hole + DNS over HTTPS
**Skills:** DNS filtering, Cloudflared DoH, threat blocklists, anomalous domain monitoring

## Deployment
Pi-hole runs as VM (CT 100) on Proxmox. Bridge: vmbr0, VLAN tag: 10. IP: `192.168.10.2`

## DNS Chain
```
Client → Pi-hole (192.168.10.2:53) → Cloudflared (127.0.0.1:5053) → Cloudflare 1.1.1.1 (HTTPS)
```

## Key Commands
```bash
# Install Pi-hole
curl -sSL https://install.pi-hole.net | bash
pihole -a -p                    # set admin password

# Install Cloudflared DoH
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb
# Config: proxy-dns-port 5053 → https://1.1.1.1/dns-query

# Update blocklists
pihole -g
```

## Blocklists
See [blocklists.md](./blocklists.md)

## Resume Bullets
> "Deployed Pi-hole VM with 1.2M+ domain blocklist aggregating OISD, Steven Black, and URLhaus threat intel"
> "Configured DNS over HTTPS via Cloudflared eliminating ISP DNS snooping and encrypting all recursive queries"
