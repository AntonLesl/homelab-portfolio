# Anton Leslie

**IT Systems Administrator | Aspiring SOC Analyst**
Calumet City, IL · [GitHub](https://github.com/AntonLesl) · [LinkedIn](https://linkedin.com/in/antonleslie)

---

## Summary

Cybersecurity and systems professional with a B.S. in Computer Science (Cybersecurity emphasis) and CompTIA Security+, plus 4+ years of hands-on experience in endpoint security, identity management, DFIR, and vulnerability management. Experienced administering enterprise Microsoft environments (Entra ID, Intune, Defender) and responding to security incidents with XDR and SIEM tooling. This repository is the practical companion to that experience — a full enterprise homelab built and documented from scratch.

---

## Certifications

- **CompTIA Security+**
- **CompTIA Network+** (in progress)

---

## Technical Skills

| Area | Tools & Technologies |
|------|----------------------|
| **Networking** | pfSense, 802.1Q VLANs, firewall rule design, NAT, DNS (Pi-hole/Unbound), Tailscale/WireGuard, Suricata IDS |
| **Security Operations** | Wazuh SIEM, MITRE ATT&CK, Stellar Cyber XDR, Greenbone/OpenVAS, incident response, DFIR |
| **Infrastructure** | Proxmox VE, LXC/KVM, Docker, Active Directory, Windows Server 2022, Linux |
| **Identity & Endpoint** | Microsoft Entra ID, on-prem AD, Intune, Microsoft 365, endpoint hardening |
| **Scripting/Tooling** | PowerShell, Bash, nmap, Wireshark, impacket |

---

## Featured Project — Enterprise Homelab

**This repository.** A production-style network, security monitoring stack, and isolated attack lab built on physical hardware, documented step-by-step with every command, reference, and troubleshooting write-up.

- **Network & firewall** — pfSense on dedicated hardware with 802.1Q VLAN segmentation (trusted vs. lab), default-deny rules, cross-VLAN NAT, and remote syslog to a SIEM.
- **Virtualization** — Proxmox VE with two Linux bridges, including a **no-uplink isolated bridge** for safely running offensive tooling.
- **Security monitoring** — Wazuh SIEM with six custom detection rules mapped to MITRE ATT&CK; Suricata IDS; Greenbone/OpenVAS vulnerability scanning (Docker-in-LXC).
- **Remote access** — Tailscale mesh VPN with subnet routing and **zero open WAN ports**.
- **Attack lab** — Windows Server 2022 AD domain controller, domain-joined Windows 10 victim, Kali attacker, and Metasploitable 2 — the target environment for Kerberoasting, Pass-the-Hash, and enumeration exercises detected via the SIEM.
- **Documentation** — every section carries a `README`, a `COMMANDS.md` (what/why/reference), and an `ISSUES.md` (35+ real problems with root cause, investigation, and fix), plus a full build journal.

**What it demonstrates:** real infrastructure build-out, network and security engineering, and — most importantly — documented troubleshooting under real hardware failures, which is the core skill of both systems administration and security operations.

---

## Experience Highlights

- **IT Systems Administration** — Administer Microsoft Entra ID and on-prem Active Directory for 500+ users; manage and enforce security baselines across Windows/macOS endpoints via Intune; triage and respond to endpoint/network security alerts.
- **Cyber Defense Analyst (Boise State)** — Conducted DFIR investigations across simulated enterprise environments; identified and prioritized vulnerabilities using Stellar Cyber XDR and Greenbone.

*Full work history available on request / LinkedIn.*

---

## Education

**B.S. Computer Science — Cybersecurity Emphasis**
Boise State University (NSA/DHS CAE-CD designated)
