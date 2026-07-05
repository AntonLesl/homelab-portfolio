# Commands — 12 Attack Exercises

> All commands run only inside the isolated lab (vmbr2, no uplink). Documented here for the blue-team detection workflow.

## Host/service discovery with nmap (Kali)

```bash
nmap -sV -p- [lab target]
```
**Why:** Enumerates open ports/services on lab targets — the reconnaissance step, and a detection opportunity in Suricata/Wazuh (MITRE T1046).
**Where learned:** https://nmap.org/book/man.html

## Kerberoasting — request service tickets (Kali / impacket)

```bash
GetUserSPNs.py [lab.domain]/[user]:[password] -dc-ip [DC] -request
```
**Why:** Requests Kerberos service tickets for accounts with SPNs so they can be cracked offline — the core of a Kerberoasting exercise (MITRE T1558.003). Generates Windows event telemetry the SIEM should catch.
**Where learned:** https://github.com/fortra/impacket

## Crack the extracted ticket offline

```bash
hashcat -m 13100 [ticket hash file] [wordlist]
```
**Why:** Demonstrates why weak service-account passwords are dangerous — the offline crack step.
**Where learned:** https://hashcat.net/wiki/

## Validate detection in Wazuh

```bash
/var/ossec/bin/wazuh-logtest
```
**Why:** After running an exercise, confirm the intended custom rule fired on the resulting log — closing the purple-team loop.
**Where learned:** https://documentation.wazuh.com/current/user-manual/ruleset/testing.html
