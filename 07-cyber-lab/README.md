# 07 — Isolated Cyber Lab
**Skills:** AD deployment, network isolation, Kali Linux, attack simulation, snapshot workflow

## Design
All VMs on vmbr2 — internal bridge with no uplink. pfSense has no route to 10.10.10.0/24.
Only outbound allowed: Wazuh agent log push on port 1514.

## VM Inventory
| VM | IP | Role | Bridge |
|----|-----|------|--------|
| Kali Linux | 10.10.10.5 | Attacker | vmbr2 |
| Windows Server 2022 | 10.10.10.10 | DC (lab.local) | vmbr2 |
| Windows 10 | 10.10.10.20 | Domain victim | vmbr2 |
| Metasploitable 2 | 10.10.10.30 | Vulnerable target | vmbr2 |

## Snapshot Workflow
```bash
# Before every exercise
qm snapshot 200 clean-state && qm snapshot 201 clean-state
qm snapshot 202 clean-state && qm snapshot 203 clean-state

# Rollback after exercise
qm rollback 200 clean-state && qm rollback 201 clean-state
qm rollback 202 clean-state && qm rollback 203 clean-state
```

## Docs
- [network-design.md](./network-design.md)
- [active-directory-setup/](./active-directory-setup/)
- [attack-exercises/](./attack-exercises/)
