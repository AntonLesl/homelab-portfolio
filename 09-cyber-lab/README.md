# 09 — Isolated Cyber Lab (Active Directory + Victims + Attacker)

**Status:** ✅ Complete
**Skills:** Active Directory, Windows Server administration, isolated lab design, attack surface creation

## What This Is

A fully isolated attack lab on Proxmox's no-uplink bridge (vmbr2), built to safely practice offensive techniques and generate real telemetry for the SIEM:

- **Windows Server 2022** — Active Directory Domain Controller (domain, users, OUs, service accounts)
- **Windows 10** — domain-joined victim workstation
- **Kali Linux** — attacker box
- **Metasploitable 2** — deliberately vulnerable Linux target

## Why an Isolated Lab

To practice attacks (Kerberoasting, Pass-the-Hash, exploitation) you need a realistic target — a domain with users and services — but you must never run offensive tooling where it can touch a real network. Placing every lab VM on a bridge with **no physical uplink** contains all traffic to a virtual switch. The only path out is the Wazuh agent forwarding logs, so the SIEM still sees the activity.

## Design

- All lab VMs on vmbr2 (isolated, no uplink)
- Windows Server 2022 promoted to a Domain Controller
- Windows 10 joined to the domain as the victim
- Kali as the attacker on the same isolated segment
- Metasploitable 2 as an additional vulnerable target
- Wazuh agents forward telemetry so attacks are detectable

## References

- AD DS install: https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services
- Kali Linux docs: https://www.kali.org/docs/
- Metasploitable 2: https://docs.rapid7.com/metasploit/metasploitable-2/
