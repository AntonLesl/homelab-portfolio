# 06 — Tailscale VPN

**Skills:** Mesh VPN, subnet routing, zero-trust remote access, Tailscale ACLs

## Subnet Routes
| Node | Advertised Subnet |
|------|-----------------|
| pfSense | 192.168.10.0/24 (VLAN 10) |
| Proxmox | 192.168.30.0/24 (VLAN 30) |

> vmbr2 (10.10.10.0/24) intentionally NOT advertised. Lab VMs accessed via Proxmox console only.

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
> "Deployed Tailscale mesh VPN on pfSense and Proxmox with subnet routing, enabling zero-trust remote access with no exposed WAN ports"
