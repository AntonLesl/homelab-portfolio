# pfSense Firewall Rules

## VLAN 10 — TRUSTED Rules
| # | Action | Source | Destination | Port | Purpose |
|---|--------|--------|-------------|------|---------|
| 1 | Allow | TRUSTED net | any | 80, 443 | Internet access |
| 2 | Allow | TRUSTED net | 192.168.10.2 | 53 | DNS to Pi-hole only |
| 3 | Block | TRUSTED net | LAB net | any | Block trusted → lab |
| 4 | Block | TRUSTED net | any | any | Default deny |

## VLAN 30 — LAB Rules
| # | Action | Source | Destination | Port | Purpose |
|---|--------|--------|-------------|------|---------|
| 1 | Allow | LAB net | any | 80, 443 | Internet for updates |
| 2 | Allow | LAB net | 192.168.10.2 | 53 | DNS to Pi-hole |
| 3 | Block | LAB net | TRUSTED net | any | Block lab → trusted |
| 4 | Block | LAB net | any | any | Default deny |

## WAN Rules
Default: block all inbound. No allow rules on WAN.

## Notes
- vmbr2 (isolated cyber lab) has no pfSense interface — isolation enforced at Proxmox hypervisor level
- Suricata runs on WAN interface in IPS mode (block offenders)
- pfSense syslog → Wazuh 192.168.30.20:514
