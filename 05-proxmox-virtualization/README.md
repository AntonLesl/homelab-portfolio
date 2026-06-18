# 05 — Proxmox VE Virtualization

**Skills:** Hypervisor deployment, virtual bridge design, VLAN integration, network isolation

## Purpose
Proxmox hosts all lab VMs and containers. Two virtual bridges split management traffic (vmbr0, VLAN 30) from the fully isolated cyber lab (vmbr2, no uplink).

## Network Bridges
| Bridge | Uplink | VLAN | Purpose |
|--------|--------|------|---------|
| vmbr0 | Physical NIC | 30 | Management — Proxmox, Wazuh, OpenVAS |
| vmbr2 | None | None | Isolated cyber lab — no external routing |

## /etc/network/interfaces
See [`network-interfaces.conf`](./network-interfaces.conf)

## Steps
1. Install Proxmox VE — set IP to `192.168.30.10/24`
2. Switch from enterprise to community repo
3. Edit `/etc/network/interfaces` with vmbr0 and vmbr2 config
4. Add static route for Wazuh log push from lab
5. Create Ubuntu 22.04 cloud-init template (VM 9000)
6. Clone template for Wazuh and OpenVAS

## Resume Bullet
> "Deployed Proxmox VE with dual virtual bridge configuration — vmbr0 on VLAN 30 for management, vmbr2 as internal-only bridge enforcing complete lab isolation at hypervisor level"
