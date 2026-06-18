# 08 — Wazuh SIEM + Detection Engineering

**Skills:** SIEM deployment, log ingestion, custom detection rules, MITRE ATT&CK mapping, incident response

## Architecture
```
pfSense syslog → Wazuh (192.168.30.20) ← Wazuh agents (all VMs)
```

## Log Sources
| Source | Method | Events |
|--------|--------|--------|
| pfSense | Syslog UDP 514 | Firewall blocks, DHCP, system |
| Kali Linux | Wazuh agent | Commands, file integrity, network |
| Windows Server 2022 | Wazuh agent | Security events, AD logs |
| Windows 10 | Wazuh agent | Security events, logon, process |
| Proxmox | Wazuh agent | System, auth |

## Install (LXC on Proxmox)
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
# Edit config.yml — set all IPs to 192.168.30.20
bash wazuh-install.sh -a
```

## Custom Rules
See [`custom-rules.xml`](./custom-rules.xml)

## Incident Reports
| # | Incident | MITRE | Report |
|---|----------|-------|--------|
| IR-001 | Kerberoasting | T1558.003 | [→](./incident-reports/IR-001-kerberoasting.md) |
| IR-002 | Pass-the-Hash | T1550.002 | [→](./incident-reports/IR-002-pass-the-hash.md) |
| IR-003 | BloodHound enum | T1087.002 | [→](./incident-reports/IR-003-bloodhound.md) |
| IR-004 | vsftpd exploit | T1190 | [→](./incident-reports/IR-004-vsftpd.md) |
| IR-005 | LSASS dump | T1003.001 | [→](./incident-reports/IR-005-lsass-dump.md) |

## Resume Bullets
> "Deployed Wazuh SIEM aggregating logs from 5+ sources including pfSense, Windows AD, and Kali Linux across isolated VLAN segments"
> "Authored custom Wazuh detection rules mapped to MITRE ATT&CK for Kerberoasting, Pass-the-Hash, LSASS dumping, and AD enumeration"
> "Produced incident response playbooks documenting attack execution, SIEM detection timeline, evidence, and remediation for each lab exercise"
