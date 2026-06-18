# pfSense Firewall Rules

## VLAN 10 — TRUSTED
| # | Action | Source | Destination | Port | Purpose |
|---|--------|--------|-------------|------|---------|
| 1 | Allow | TRUSTED net | any | 80, 443 | Internet access |
| 2 | Allow | TRUSTED net | 192.168.10.2 | 53 | DNS to Pi-hole only |
| 3 | Block | TRUSTED net | LAB net | any | Block trusted → lab |
| 4 | Block | TRUSTED net | any | any | Default deny |

## VLAN 30 — LAB
| # | Action | Source | Destination | Port | Purpose |
|---|--------|--------|-------------|------|---------|
| 1 | Allow | LAB net | any | 80, 443 | Internet for updates |
| 2 | Allow | LAB net | 192.168.10.2 | 53 | DNS to Pi-hole |
| 3 | Block | LAB net | TRUSTED net | any | Block lab → trusted |
| 4 | Block | LAB net | any | any | Default deny |

## WAN
Default: block all inbound. Zero allow rules. Tailscale handles remote access.

## Notes
- vmbr2 has no pfSense interface — isolation enforced at Proxmox hypervisor
- Suricata WAN IPS mode — install at Step 12 (last)
- pfSense syslog → Wazuh 192.168.30.20:514
