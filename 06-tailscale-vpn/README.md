# 06 — Tailscale VPN

**Skills:** Mesh VPN, subnet routing, zero-trust remote access, Tailscale ACL policy

## Purpose
Tailscale provides encrypted remote access to the homelab from any device with no open ports on the WAN firewall. Runs on pfSense and Proxmox as subnet routers.

## Subnet Routes Advertised
| Node | Advertised Subnet |
|------|-----------------|
| pfSense | 192.168.10.0/24 (VLAN 10) |
| Proxmox | 192.168.30.0/24 (VLAN 30) |

> vmbr2 (10.10.10.0/24) is intentionally NOT advertised. Lab VMs accessed via Proxmox console only.

## Install on Proxmox
```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --advertise-routes=192.168.30.0/24 --ssh --accept-dns=false
systemctl enable tailscaled
```

## Install on pfSense
System → Package Manager → search `tailscale` → install
VPN → Tailscale → Authenticate → enable subnet route `192.168.10.0/24`

## Tailscale ACL Policy
```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["autogroup:member"],
      "dst": ["192.168.10.0/24:*", "192.168.30.0/24:*"]
    }
  ]
}
```

## Resume Bullet
> "Deployed Tailscale mesh VPN on pfSense and Proxmox advertising subnet routes for VLAN 10 and 30, enabling zero-trust remote access with no exposed WAN ports"
