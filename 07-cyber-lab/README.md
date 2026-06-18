# 07 — Isolated Cyber Lab

**Skills:** AD deployment, network isolation, Kali Linux, attack simulation, snapshot workflow

## Design
All attack and defense VMs run exclusively on vmbr2 — Proxmox's internal-only bridge with no physical uplink. pfSense has no route to 10.10.10.0/24. The only outbound path is Wazuh agent log push on port 1514.

## VM Inventory
| VM | IP | Role | Bridge |
|----|-----|------|--------|
| Kali Linux | 10.10.10.5 | Attacker | vmbr2 |
| Windows Server 2022 | 10.10.10.10 | Domain controller (lab.local) | vmbr2 |
| Windows 10 | 10.10.10.20 | Domain-joined victim | vmbr2 |
| Metasploitable 2 | 10.10.10.30 | Vulnerable Linux target | vmbr2 |

## What Can Talk to What
| Source | Destination | Allowed |
|--------|------------|---------|
| Kali | Windows AD / Win10 | Yes — shared vmbr2 |
| Kali | Wazuh (192.168.30.20) | Port 1514 only |
| Kali | Internet | No |
| Kali | VLAN 10 / VLAN 30 | No |
| Any lab VM | Proxmox mgmt | No |

## Setup Docs
- [Active Directory Setup](./active-directory-setup/README.md)
- [Attack Exercises](./attack-exercises/)
- [Network Design](./network-design.md)

## Snapshot Workflow
```bash
# Before every exercise
qm snapshot 201 clean-state --description "Before lab"
qm snapshot 202 clean-state --description "Before lab"
qm snapshot 203 clean-state --description "Before lab"

# Restore after exercise
qm rollback 201 clean-state
qm rollback 202 clean-state
qm rollback 203 clean-state
```
