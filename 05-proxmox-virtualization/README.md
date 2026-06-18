# 05 — Proxmox VE Virtualization

**Skills:** Hypervisor deployment, virtual bridge design, network isolation

## Bridge Design
| Bridge | Uplink | VLAN | Purpose |
|--------|--------|------|---------|
| vmbr0 | Physical NIC | 30 | Management — Proxmox, Wazuh, OpenVAS, Pi-hole |
| vmbr2 | None | None | Isolated cyber lab — zero external routing |

## Network Config
See [`network-interfaces.conf`](./network-interfaces.conf)

## VM Inventory
| CT/VM ID | Name | Bridge | IP |
|----------|------|--------|-----|
| 100 | pihole | vmbr0 (VLAN 10) | 192.168.10.2 |
| 101 | wazuh | vmbr0 (VLAN 30) | 192.168.30.20 |
| 200 | kali-attacker | vmbr2 | 10.10.10.5 |
| 201 | dc01 | vmbr2 | 10.10.10.10 |
| 202 | win10 | vmbr2 | 10.10.10.20 |
| 203 | metasploitable | vmbr2 | 10.10.10.30 |
| 204 | openvas | vmbr0 (VLAN 30) | 192.168.30.30 |

## Resume Bullet
> "Deployed Proxmox VE with vmbr0 on VLAN 30 for management and vmbr2 as internal-only bridge enforcing hypervisor-level cyber lab isolation"
