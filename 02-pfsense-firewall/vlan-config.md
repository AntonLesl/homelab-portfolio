# VLAN Configuration

## VLANs on LAN Interface
| VLAN | Name | IP | DHCP Range | DNS |
|------|------|----|------------|-----|
| 10 | TRUSTED | 192.168.10.1/24 | .100–.200 | 192.168.10.2 only |
| 30 | LAB | 192.168.30.1/24 | .100–.200 | 192.168.10.2 only |

## Static DHCP Leases
| Device | IP |
|--------|-----|
| Pi-hole VM | 192.168.10.2 |
| Proxmox | 192.168.30.10 |
| Wazuh | 192.168.30.20 |
| OpenVAS | 192.168.30.30 |
| Switch | 192.168.30.200 |

## Critical Setting
DNS Server 1: `192.168.10.2` only. No backup DNS. Forces all clients through Pi-hole — no bypass.
