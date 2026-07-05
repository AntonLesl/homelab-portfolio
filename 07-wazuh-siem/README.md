# 07 — Wazuh SIEM

**Status:** ✅ Complete
**Skills:** SIEM deployment, agent management, custom detection rules, MITRE ATT&CK mapping, log correlation

## What This Is

Wazuh — an open-source SIEM/XDR — deployed on Proxmox, collecting logs from pfSense and endpoint agents (including the isolated lab hosts), with six custom detection rules mapped to MITRE ATT&CK techniques.

## Why Wazuh

Wazuh provides SIEM, host-based intrusion detection, log analysis, and file integrity monitoring in one open-source platform. It ingests syslog from the firewall and agent telemetry from Windows/Linux hosts, so security events across the whole environment land in one searchable place — exactly the workflow a SOC analyst uses.

## Design

- Wazuh manager + dashboard on Proxmox
- pfSense forwards syslog (firewall/DHCP/auth/system) to the manager
- Agents on lab hosts forward telemetry (lab hosts can reach the SIEM for logs only)
- Six custom rules mapped to MITRE ATT&CK cover the attack techniques rehearsed in the lab

## References

- Wazuh install guide: https://documentation.wazuh.com/current/installation-guide/
- Custom rules: https://documentation.wazuh.com/current/user-manual/ruleset/custom.html
- MITRE ATT&CK: https://attack.mitre.org/
