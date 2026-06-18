# Network Topology

## Full Diagram

```
                        ┌──────────────────┐
                        │   ISP / Internet  │
                        └────────┬─────────┘
                                 │
                        ┌────────▼─────────┐
                        │  GL.iNet Slate 7  │  WAN entry · DMZ passthrough
                        └────────┬─────────┘
                                 │
                        ┌────────▼──────────────────┐
                        │   pfSense (physical device) │
                        │  VLAN 10 → 192.168.10.1    │
                        │  VLAN 30 → 192.168.30.1    │
                        └────────┬──────────────────┘
                                 │ trunk (VLANs 10, 30)
                   ┌─────────────▼──────────────────────┐
                   │        8-Port Managed Switch         │
                   └──────┬──────────┬──────────┬────────┘
                          │          │           │
                   ┌──────▼───┐ ┌────▼───┐ ┌────▼───────────────────────────────┐
                   │ Pi-hole  │ │ Laptop │ │            Proxmox VE               │
                   │ VM VLAN10│ │ VLAN10 │ │         192.168.30.10               │
                   │.10.2     │ │.10.x   │ │  vmbr0 (VLAN 30)                   │
                   └──────────┘ └────────┘ │  ├── Wazuh SIEM  192.168.30.20     │
                                           │  └── OpenVAS     192.168.30.30     │
                                           │  vmbr2 (NO UPLINK · ISOLATED)      │
                                           │  ├── Kali Linux    10.10.10.5      │
                                           │  ├── Windows AD    10.10.10.10     │
                                           │  ├── Windows 10    10.10.10.20     │
                                           │  └── Metasploitable 10.10.10.30    │
                                           └────────────────────────────────────┘
Tailscale VPN · pfSense + Proxmox · zero open WAN ports
```

## IP Address Scheme

### VLAN 10 — Trusted (192.168.10.0/24)
| Device | IP | Notes |
|--------|-----|-------|
| pfSense gateway | 192.168.10.1 | VLAN 10 interface |
| Pi-hole VM | 192.168.10.2 | VM on Proxmox vmbr0 VLAN 10 |
| Trusted laptop | 192.168.10.100–200 | DHCP range |

### VLAN 30 — Lab Infrastructure (192.168.30.0/24)
| Device | IP | Notes |
|--------|-----|-------|
| pfSense gateway | 192.168.30.1 | VLAN 30 interface |
| Proxmox VE | 192.168.30.10 | Static |
| Wazuh SIEM | 192.168.30.20 | Static — LXC on vmbr0 |
| OpenVAS | 192.168.30.30 | Static — VM on vmbr0 |
| Switch management | 192.168.30.200 | Static |

### vmbr2 — Isolated Cyber Lab (10.10.10.0/24)
| Device | IP | Notes |
|--------|-----|-------|
| Kali Linux | 10.10.10.5 | Attacker VM |
| Windows Server 2022 | 10.10.10.10 | Domain controller (lab.local) |
| Windows 10 | 10.10.10.20 | Domain-joined victim |
| Metasploitable 2 | 10.10.10.30 | Vulnerable Linux target |

## Switch Port Assignment
| Port | Mode | VLAN | Device |
|------|------|------|--------|
| 1 | Trunk | 10, 30 | pfSense LAN port |
| 2 | Access | 10 | Pi-hole VM |
| 3 | Access | 10 | Trusted laptop |
| 4 | Access | 30 | Proxmox server |
| 5–8 | Spare | — | Available |

## Traffic Rules
| Source | Destination | Action | Enforced by |
|--------|------------|--------|-------------|
| VLAN 10 | Internet | Allow | pfSense |
| VLAN 10 | VLAN 30 | Block | pfSense |
| VLAN 30 | Internet | Allow (updates) | pfSense |
| VLAN 30 | VLAN 10 | Block | pfSense |
| vmbr2 | Internet | Block | Proxmox (no uplink) |
| vmbr2 | 192.168.30.20:1514 | Allow | Proxmox static route |
