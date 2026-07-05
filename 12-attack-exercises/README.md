# 12 — Attack Exercises & Incident Response

**Status:** 🔄 In Progress
**Skills:** Offensive technique execution, blue-team detection, incident documentation, MITRE ATT&CK

## What This Is

The payoff of the whole build: running real attack techniques inside the isolated lab, watching them surface in Wazuh/Suricata, and writing up each one as an incident report — the full purple-team loop.

## Why This Matters

Building infrastructure is half the skill; detecting and responding to attacks on it is the other half. Each exercise is run from Kali against the AD domain, detected via the SIEM/IDS, and documented as an incident report (IR) with the MITRE technique, detection evidence, and response steps — exactly the artifacts a SOC analyst produces.

## Planned / In-Progress Exercises

| Exercise | MITRE Technique | Status |
|----------|-----------------|--------|
| Kerberoasting | T1558.003 | 🔄 |
| Pass-the-Hash | T1550.002 | ⏳ |
| Network/host enumeration (nmap) | T1046 | ⏳ |
| Metasploitable exploitation | T1210 | ⏳ |
| Brute force / password spray | T1110 | ⏳ |

Each completed exercise gets an incident report in `incident-reports/` (IR-001, IR-002, …).

## References

- MITRE ATT&CK: https://attack.mitre.org/
- Kerberoasting (T1558.003): https://attack.mitre.org/techniques/T1558/003/
- Pass-the-Hash (T1550.002): https://attack.mitre.org/techniques/T1550/002/
