# Cyber Lab Network Design

## vmbr2 Isolation
`bridge-ports none` — no physical NIC. pfSense has no interface to 10.10.10.0/24.
Only outbound: Proxmox host-level static route to Wazuh 192.168.30.20:1514.

## /etc/hosts on All Lab VMs
```
10.10.10.5    kali
10.10.10.10   dc01 dc01.lab.local
10.10.10.20   win10 win10.lab.local
10.10.10.30   metasploitable
```

## Traffic Rules
| Source | Destination | Allowed |
|--------|------------|---------|
| Kali | Windows AD / Win10 | Yes — shared vmbr2 |
| Any lab VM | 192.168.30.20:1514 | Yes — Wazuh logs only |
| Any lab VM | Internet | No |
| Any lab VM | VLAN 10 / 30 | No |
