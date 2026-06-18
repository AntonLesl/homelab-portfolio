# 08 — Wazuh SIEM + Detection Engineering

**Skills:** SIEM deployment, log ingestion, MITRE ATT&CK rules, IR playbooks

## Log Sources
| Source | Method | Key Events |
|--------|--------|-----------|
| pfSense | Syslog UDP 514 | Firewall blocks, DHCP |
| Kali Linux | Wazuh agent | Commands, network |
| Windows Server 2022 | Wazuh agent | AD security events |
| Windows 10 | Wazuh agent | Logon, process creation |

## Install
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
# Edit config.yml — set all IPs to 192.168.30.20
bash wazuh-install.sh -a
```

## Custom Rules
See [`custom-rules.xml`](./custom-rules.xml) — 6 rules covering T1558.003, T1550.002, T1003.001, T1003.006, T1046, T1110

## Incident Reports
| # | Incident | MITRE |
|---|----------|-------|
| [IR-001](./incident-reports/IR-001-kerberoasting.md) | Kerberoasting | T1558.003 |
| [IR-002](./incident-reports/IR-002-pass-the-hash.md) | Pass-the-Hash | T1550.002 |
| [IR-003](./incident-reports/IR-003-bloodhound.md) | BloodHound enum | T1087.002 |
| [IR-004](./incident-reports/IR-004-vsftpd.md) | vsftpd exploit | T1190 |
| [IR-005](./incident-reports/IR-005-lsass-dump.md) | LSASS dump | T1003.001 |

## Resume Bullets
> "Deployed Wazuh SIEM aggregating logs from 5+ sources across isolated VLAN segments"
> "Authored custom Wazuh rules mapped to MITRE ATT&CK for 6 AD attack techniques"
> "Produced 5 incident response playbooks with attack execution, SIEM evidence, and remediation"
