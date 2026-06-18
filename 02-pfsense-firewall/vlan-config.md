# VLAN Configuration

## VLANs Created on LAN Interface

| VLAN Tag | Name | Interface IP | DHCP Range | DNS Served |
|----------|------|-------------|------------|-----------|
| 10 | TRUSTED | 192.168.10.1/24 | .100–.200 | 192.168.10.2 (Pi-hole) |
| 30 | LAB | 192.168.30.1/24 | .100–.200 | 192.168.10.2 (Pi-hole) |

## Static DHCP Leases

| Device | MAC | IP |
|--------|-----|----|
| Pi-hole | (Pi-hole MAC) | 192.168.10.2 |
| Proxmox | (Proxmox MAC) | 192.168.30.10 |
| Wazuh | (Wazuh VM MAC) | 192.168.30.20 |
| OpenVAS | (OpenVAS VM MAC) | 192.168.30.30 |
| Switch | (Switch MAC) | 192.168.30.200 |

## Critical DHCP Setting
DNS Server 1: `192.168.10.2` (Pi-hole only)
DNS Server 2: (blank — forces all DNS through Pi-hole, no bypass possible)
