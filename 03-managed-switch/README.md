# 03 — Managed Switch VLAN Configuration

**Skills:** 802.1Q trunking, access port assignment, layer-2 isolation

## Port Assignment
| Port | Mode | VLAN | Device |
|------|------|------|--------|
| 1 | Trunk | 10, 30 | pfSense LAN port |
| 2 | Access | 10 | Pi-hole |
| 3 | Access | 10 | Trusted laptop |
| 4 | Access | 30 | Proxmox server |
| 5–8 | Spare | — | — |

## Configuration (TP-Link TL-SG108E)
1. Set switch mgmt IP to `192.168.30.200`
2. Create VLAN 10: Port 1 Tagged, Ports 2–3 Untagged
3. Create VLAN 30: Port 1 Tagged, Port 4 Untagged
4. Set PVID: Port 2 → 10, Port 3 → 10, Port 4 → 30
5. Apply and verify devices receive correct IPs

## Resume Bullet
> "Configured 8-port managed switch with 802.1Q VLAN trunking, assigning access ports per segment to enforce layer-2 traffic isolation"
