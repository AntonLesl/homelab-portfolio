# 04 — Pi-hole + DNS over HTTPS

**Skills:** Network-wide DNS filtering, Cloudflared DoH, threat blocklists, anomalous domain monitoring

## Purpose
Pi-hole intercepts every DNS query on the network and filters against threat blocklists. Cloudflared encrypts all outbound DNS over HTTPS so the ISP sees zero DNS traffic.

## Architecture
```
Client → Pi-hole (192.168.10.2:53) → Cloudflared (127.0.0.1:5053) → Cloudflare 1.1.1.1 (DoH)
```

## Steps
1. Create LXC in Proxmox — Ubuntu 22.04, IP `192.168.10.2`, VLAN 10, vmbr0
2. Install Pi-hole: `curl -sSL https://install.pi-hole.net | bash`
3. Install cloudflared and configure as DoH proxy on port 5053
4. Point Pi-hole upstream DNS to `127.0.0.1#5053`
5. Add blocklists (see [blocklists.md](./blocklists.md))
6. Run `pihole -g` to update gravity
7. Set pfSense DHCP to serve only `192.168.10.2` as DNS

## Cloudflared Install
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb
mkdir -p /etc/cloudflared
cat > /etc/cloudflared/config.yml << CONF
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
CONF
cloudflared service install
systemctl enable --now cloudflared
```

## Resume Bullets
> "Deployed Pi-hole DNS sinkhole with 1.2M+ domain blocklist aggregating OISD, Steven Black, and URLhaus threat intel"
> "Configured DNS over HTTPS via Cloudflared eliminating ISP DNS visibility and encrypting all recursive queries"
