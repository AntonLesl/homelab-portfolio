# 06 — Tailscale VPN
**Skills:** Mesh VPN, subnet routing, zero-trust remote access, ACL policy

## Subnet Routes Advertised
| Node | Subnet |
|------|--------|
| pfSense | 192.168.10.0/24 |
| Proxmox | 192.168.30.0/24 |

> vmbr2 (10.10.10.0/24) NOT advertised. Lab VMs accessed via Proxmox console only.

## Install on Proxmox
```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --advertise-routes=192.168.30.0/24 --ssh --accept-dns=false
systemctl enable tailscaled
```

## ACL Policy
```json
{
  "acls": [{ "action": "accept", "src": ["autogroup:member"],
    "dst": ["192.168.10.0/24:*", "192.168.30.0/24:*"] }]
}
```

## Resume Bullet
> "Deployed Tailscale mesh VPN on pfSense and Proxmox with subnet routing — zero-trust remote access, no exposed WAN ports"
