<div align="center">

# 🛡️ Anton Leslie — Homelab & Cybersecurity Portfolio

**IT Systems Administrator · CompTIA Security+ · B.S. Computer Science (Cybersecurity Emphasis)**

[![Security+](https://img.shields.io/badge/CompTIA-Security%2B-red?style=for-the-badge&logo=comptia&logoColor=white)](https://www.comptia.org/certifications/security)
[![Network+](https://img.shields.io/badge/CompTIA-Network%2B_In_Progress-orange?style=for-the-badge&logo=comptia&logoColor=white)](https://www.comptia.org/certifications/network)
[![NSA CAE](https://img.shields.io/badge/NSA%2FDHS-CAE_Cyber_Defense-blue?style=for-the-badge&logoColor=white)](#)
[![LinkedIn](https://www.linkedin.com/in/anton-leslie-618071238/)

📍 Calumet City, IL &nbsp;|&nbsp; 📧 tieyonleslie00@gmail.com &nbsp;|&nbsp; ☎️ (312) 771-4407

</div>

---

## About This Repository

This portfolio documents a fully designed and implemented enterprise-grade homelab built to develop and demonstrate real-world skills in network security, firewall administration, DNS hardening, virtualization, Active Directory, SIEM operations, and hands-on attack/defense practice.

Every section includes step-by-step configuration, working commands, architecture decisions, and evidence of implementation — built to mirror what SOC Analysts, Systems Administrators, and IT Security Analysts do on the job.

---

## Network Architecture

```
                        ┌──────────────────┐
                        │   ISP / Internet  │
                        └────────┬─────────┘
                                 │
                        ┌────────▼─────────┐
                        │  GL.iNet Slate 7  │  ← WAN entry · DMZ passthrough
                        └────────┬─────────┘
                                 │
                        ┌────────▼──────────────────┐
                        │       pfSense Firewall      │
                        │  VLAN 10 → 192.168.10.1    │  ← Firewall · Suricata IDS/IPS
                        │  VLAN 30 → 192.168.30.1    │  ← DHCP · NAT · syslog → Wazuh
                        └────────┬──────────────────┘
                                 │ trunk (VLANs 10, 30)
                   ┌─────────────▼──────────────────────┐
                   │        8-Port Managed Switch         │  ← 802.1Q VLAN distribution
                   └──────┬──────────┬──────────┬────────┘
                          │          │           │
                   ┌──────▼───┐ ┌────▼───┐ ┌────▼───────────────────────────────┐
                   │ Pi-hole  │ │ Laptop │ │            Proxmox VE               │
                   │ VLAN 10  │ │ VLAN10 │ │         192.168.30.10               │
                   │.10.2     │ │.10.x   │ │                                     │
                   │ DNS+DoH  │ └────────┘ │  ┌─ vmbr0 (VLAN 30) ─────────────┐ │
                   └──────────┘            │  │  Wazuh SIEM  192.168.30.20    │ │
                                           │  │  OpenVAS     192.168.30.30    │ │
                                           │  └───────────────────────────────┘ │
                                           │                                     │
                                           │  ┌─ vmbr2 (NO UPLINK · ISOLATED) ─┐│
                                           │  │  Kali Linux    10.10.10.5      ││
                                           │  │  Windows AD    10.10.10.10     ││
                                           │  │  Windows 10    10.10.10.20     ││
                                           │  │  Metasploitable 10.10.10.30    ││
                                           │  │  ↑ Wazuh logs only · port 1514 ││
                                           │  └────────────────────────────────┘│
                                           └────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Tailscale VPN overlay · pfSense + Proxmox · zero open WAN ports   │
│  Remote access to VLAN 10 + VLAN 30 from anywhere                  │
└─────────────────────────────────────────────────────────────────────┘
```

📄 [Full topology, IP table, and traffic rules →](./TOPOLOGY.md)

---

## Project Sections

### Infrastructure

| # | Project | Skills Demonstrated | Docs |
|---|---------|-------------------|------|
| 01 | **GL.iNet Slate 7 — WAN Setup** | DMZ mode, WAN passthrough, router hardening | [→ View](./01-slate7-wan-setup/README.md) |
| 02 | **pfSense Firewall** | VLAN segmentation, firewall rules, Suricata IDS/IPS, DHCP | [→ View](./02-pfsense-firewall/README.md) |
| 03 | **Managed Switch — VLAN Config** | 802.1Q trunking, access port assignment, layer-2 isolation | [→ View](./03-managed-switch/README.md) |
| 04 | **Pi-hole + DNS over HTTPS** | DNS filtering, Cloudflared DoH, 1M+ threat blocklists | [→ View](./04-pihole-dns/README.md) |
| 05 | **Proxmox VE — Virtualization** | Hypervisor setup, virtual bridge design, network isolation | [→ View](./05-proxmox-virtualization/README.md) |
| 06 | **Tailscale VPN** | Subnet routing, zero-trust remote access, Tailscale ACLs | [→ View](./06-tailscale-vpn/README.md) |

### Cybersecurity Lab

| # | Project | Skills Demonstrated | Docs |
|---|---------|-------------------|------|
| 07 | **Isolated Cyber Lab** | AD deployment, network isolation, Kali, Metasploitable | [→ View](./07-cyber-lab/README.md) |
| 08 | **Wazuh SIEM + Detection Rules** | Log ingestion, MITRE ATT&CK rules, IR playbooks, alerting | [→ View](./08-wazuh-siem/README.md) |

---

## Security Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Zero inter-VLAN trust** | pfSense denies all cross-segment traffic by default — explicit allow rules only |
| **Hypervisor-enforced isolation** | Cyber lab on `vmbr2` — bridge with no physical uplink, no VLAN, no external route |
| **Encrypted DNS** | All queries → Pi-hole → Cloudflared → Cloudflare 1.1.1.1 over HTTPS |
| **No exposed ports** | Tailscale mesh VPN — zero inbound rules on WAN |
| **One-way log channel** | Wazuh agents push logs out on port 1514 only — management unreachable from lab |
| **MITRE ATT&CK mapped detection** | Custom rules cover T1558.003, T1550.002, T1003.001, T1003.006, T1046, T1110 |

---

## Attack Exercises & Incident Reports

| Exercise | MITRE ATT&CK | Detection | Report |
|----------|-------------|-----------|--------|
| Kerberoasting | [T1558.003](https://attack.mitre.org/techniques/T1558/003/) | Event 4769 — RC4 TGS request | [→ IR-001](./08-wazuh-siem/incident-reports/IR-001-kerberoasting.md) |
| Pass-the-Hash | [T1550.002](https://attack.mitre.org/techniques/T1550/002/) | Event 4624 — NTLM network logon | [→ IR-002](./08-wazuh-siem/incident-reports/IR-002-pass-the-hash.md) |
| BloodHound enumeration | [T1087.002](https://attack.mitre.org/techniques/T1087/002/) | Event 4662 — LDAP replication | [→ IR-003](./08-wazuh-siem/incident-reports/IR-003-bloodhound.md) |
| Metasploit vsftpd exploit | [T1190](https://attack.mitre.org/techniques/T1190/) | Suricata + process alert | [→ IR-004](./08-wazuh-siem/incident-reports/IR-004-vsftpd.md) |
| LSASS credential dump | [T1003.001](https://attack.mitre.org/techniques/T1003/001/) | Event 4656 — LSASS handle | [→ IR-005](./08-wazuh-siem/incident-reports/IR-005-lsass-dump.md) |

---

## IP Address Reference

<details>
<summary>Click to expand full IP table</summary>

### VLAN 10 — Trusted (192.168.10.0/24)
| Device | IP | Role |
|--------|-----|------|
| pfSense gateway | 192.168.10.1 | Default gateway |
| Pi-hole | 192.168.10.2 | DNS (static) |
| Trusted laptop | 192.168.10.100–200 | DHCP |

### VLAN 30 — Lab Infrastructure (192.168.30.0/24)
| Device | IP | Role |
|--------|-----|------|
| pfSense gateway | 192.168.30.1 | Default gateway |
| Proxmox VE | 192.168.30.10 | Hypervisor (static) |
| Wazuh SIEM | 192.168.30.20 | Log aggregation (static) |
| OpenVAS | 192.168.30.30 | Vuln scanner (static) |
| Switch | 192.168.30.200 | Management (static) |

### vmbr2 — Isolated Cyber Lab (10.10.10.0/24)
| Device | IP | Role |
|--------|-----|------|
| Kali Linux | 10.10.10.5 | Attacker |
| Windows Server 2022 | 10.10.10.10 | Domain controller |
| Windows 10 | 10.10.10.20 | Victim workstation |
| Metasploitable 2 | 10.10.10.30 | Vulnerable target |

</details>

---

## Tools & Technologies

<div align="center">

![pfSense](https://img.shields.io/badge/pfSense-Firewall-003399?style=flat-square)
![Suricata](https://img.shields.io/badge/Suricata-IDS%2FIPS-EF3B2D?style=flat-square)
![Proxmox](https://img.shields.io/badge/Proxmox-Virtualization-E57000?style=flat-square)
![Wazuh](https://img.shields.io/badge/Wazuh-SIEM-00A4EF?style=flat-square)
![Pi-hole](https://img.shields.io/badge/Pi--hole-DNS_Filter-96060C?style=flat-square)
![Tailscale](https://img.shields.io/badge/Tailscale-VPN-246FDB?style=flat-square)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-Attacker-268BEE?style=flat-square)
![Windows Server](https://img.shields.io/badge/Windows_Server_2022-AD-0078D4?style=flat-square&logo=windows&logoColor=white)
![BloodHound](https://img.shields.io/badge/BloodHound-AD_Enum-FF0000?style=flat-square)
![Metasploit](https://img.shields.io/badge/Metasploit-Exploitation-2596BE?style=flat-square)
![OpenVAS](https://img.shields.io/badge/OpenVAS-Vuln_Scan-4CAF50?style=flat-square)
![Entra ID](https://img.shields.io/badge/Microsoft_Entra_ID-IAM-0078D4?style=flat-square&logo=microsoft&logoColor=white)
![Intune](https://img.shields.io/badge/Microsoft_Intune-MDM-0078D4?style=flat-square&logo=microsoft&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-Scripting-5391FE?style=flat-square&logo=powershell&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Scripting-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![SonicWall](https://img.shields.io/badge/SonicWall-Security-FF6600?style=flat-square)
![Stellar Cyber](https://img.shields.io/badge/Stellar_Cyber-XDR-6B21A8?style=flat-square)
![Atera](https://img.shields.io/badge/Atera-RMM-00B4D8?style=flat-square)

</div>

---

## Certifications

| Certification | Status |
|--------------|--------|
| CompTIA Security+ | ✅ Completed |
| CompTIA Network+ | 🔄 In Progress |
| NSA/DHS CAE Cyber Defense — Boise State University | ✅ Designated |

---

## Professional Background

| Role | Organization | Technologies |
|------|-------------|-------------|
| Campus IT Systems Support | University IT Dept | Entra ID, AD, Intune, SonicWall, Atera RMM |
| Geek Squad Consultant & ARA | Best Buy | M365, Exchange Online, endpoint security |
| Cyber Defense Analyst | BSU Institute of Pervasive Cybersecurity | Stellar Cyber XDR, Greenbone VM, DFIR |
| Help Desk Analyst | SYKES | Service desk, Active Directory, ticketing |

---

<div align="center">

*Built hands-on. Documented for real. Every command in this repo has been run.*

</div>
