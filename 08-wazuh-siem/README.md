# 08 — Wazuh SIEM + Detection Engineering
**Skills:** SIEM deployment, log ingestion, MITRE ATT&CK rules, incident response

## Log Sources
| Source | Method | Key Events |
|--------|--------|-----------|
| pfSense | Syslog UDP 514 | Firewall blocks, DHCP |
| Kali Linux | Wazuh agent | Commands, network |
| Windows Server 2022 | Wazuh agent | AD security events (4769, 4662) |
| Windows 10 | Wazuh agent | Logon, process creation (4624, 4656) |

## Install
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
# Edit config.yml — set all IPs to 192.168.30.20
bash wazuh-install.sh -a
# Save the admin password printed at the end
```

## Custom Rules
See [custom-rules.xml](./custom-rules.xml)

## Incident Reports
| # | Technique | MITRE | Report |
|---|-----------|-------|--------|
| IR-001 | Kerberoasting | T1558.003 | [→](./incident-reports/IR-001-kerberoasting.md) |
| IR-002 | Pass-the-Hash | T1550.002 | [→](./incident-reports/IR-002-pass-the-hash.md) |
| IR-003 | BloodHound enum | T1087.002 | [→](./incident-reports/IR-003-bloodhound.md) |
| IR-004 | vsftpd exploit | T1190 | [→](./incident-reports/IR-004-vsftpd.md) |
| IR-005 | LSASS dump | T1003.001 | [→](./incident-reports/IR-005-lsass-dump.md) |

## Resume Bullets
> "Deployed Wazuh SIEM aggregating logs from 5+ sources across isolated VLAN segments"
> "Authored custom Wazuh rules mapped to MITRE ATT&CK for 6 AD attack techniques"
> "Produced 5 incident response playbooks with attack execution, SIEM evidence, and remediation"
