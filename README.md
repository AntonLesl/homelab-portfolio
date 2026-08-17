<p align="center">
  <img src="./assets/hero-banner.png" alt="Anton Leslie" width="100%">
</p>

<h1 align="center">Enterprise Homelab Portfolio</h1>

<p align="center"><b>Anton Leslie</b> — IT Systems Administrator | CompTIA Security+ | B.S. Computer Science (Cybersecurity Emphasis, Boise State — NSA/DHS CAE-CD)</p>

A complete enterprise-grade network, security monitoring stack, and isolated attack lab built from scratch on physical hardware. Every section documents what was built, every command used (with references), and every problem hit along the way with its root cause and fix.

![Security+](https://img.shields.io/badge/CompTIA%20Security%2B-Earned-c97a53?style=flat-square&labelColor=1a0a0a)
![Network+](https://img.shields.io/badge/CompTIA%20Network%2B-In%20Progress-ffc9a8?style=flat-square&labelColor=1a0a0a)
![Roadmap](https://img.shields.io/badge/Roadmap-1%2F7%20Certs%20Earned-c97a53?style=flat-square&labelColor=1a0a0a)
![Status](https://img.shields.io/badge/Homelab-11%2F12%20Sections%20Complete-c97a53?style=flat-square&labelColor=1a0a0a)

> **Note on sanitization:** All internal IP addresses, hostnames of note, and credentials are deliberately omitted or replaced with placeholders like `[firewall LAN IP]`. This repository is public.

---

## 🗺️ Certification Roadmap

This homelab is the hands-on half of a deliberate plan: Security+ → Network+ → CCNA → Linux Essentials → AWS Cloud Practitioner → Microsoft SC-300 → Okta Certified Professional — a broad, deliberately-ordered path, not a bet on one narrow job title.

**→ Full visual roadmap, timeline, and the reasoning behind the order: [ROADMAP.md](./ROADMAP.md)**
**→ The daily study rhythm behind it: [DAILY-STUDY-PLAN.md](./DAILY-STUDY-PLAN.md)**

---

## Network Topology

```
                         INTERNET (ISP)
                               │
                 ┌─────────────▼─────────────┐
                 │  GL.iNet Slate 7 (DMZ)    │  WAN entry — passes all traffic
                 └─────────────┬─────────────┘  to the firewall (no double-NAT)
                               │
                 ┌─────────────▼─────────────┐
                 │  pfSense CE Firewall      │  Lenovo ThinkCentre M60E
                 │  Trusted LAN + Lab VLAN   │  Suricata IDS on LAN
                 └─────────────┬─────────────┘
                               │ 802.1Q trunk
                 ┌─────────────▼─────────────┐
                 │  Netgear GS308E Switch    │  Advanced 802.1Q mode
                 │  Access ports per VLAN    │
                 └──────┬──────────────┬─────┘
              Trusted LAN         Lab VLAN
           (workstations)              │
                              ┌────────▼────────────────────────┐
                              │  Proxmox VE Hypervisor          │
                              │                                 │
                              │  vmbr0 — management services    │
                              │   ├─ Pi-hole + Unbound DNS      │
                              │   ├─ Wazuh SIEM                 │
                              │   ├─ OpenVAS scanner            │
                              │   └─ Homepage dashboard         │
                              │                                 │
                              │  vmbr2 — ISOLATED (no uplink)   │
                              │   ├─ Windows Server 2022 (AD DC)│
                              │   ├─ Windows 10 (victim)        │
                              │   ├─ Kali Linux (attacker)      │
                              │   └─ Metasploitable 2           │
                              └─────────────────────────────────┘

   Tailscale mesh VPN overlays pfSense + Proxmox — remote access with ZERO open WAN ports
```

---

## Project Sections

| # | Section | Status | Skills Demonstrated |
|---|---------|--------|---------------------|
| 01 | [Slate 7 WAN Setup](./01-slate7-wan-setup/) | ✅ Complete | DMZ mode, WAN passthrough, router hardening |
| 02 | [pfSense Firewall](./02-pfsense-firewall/) | ✅ Complete | VLAN segmentation, rule design, DHCP, NAT |
| 03 | [Managed Switch](./03-managed-switch/) | ✅ Complete | 802.1Q trunking, access ports, PVID |
| 04 | [Proxmox Virtualization](./04-proxmox-virtualization/) | ✅ Complete | Hypervisor, virtual bridges, LXC/VM lifecycle |
| 05 | [Pi-hole + Unbound DNS](./05-pihole-dns/) | ✅ Complete | Recursive DNS, network-wide filtering |
| 06 | [Tailscale VPN](./06-tailscale-vpn/) | ✅ Complete | Zero-trust mesh VPN, subnet routing, ACLs |
| 07 | [Wazuh SIEM](./07-wazuh-siem/) | ✅ Complete | SIEM deployment, custom MITRE ATT&CK rules |
| 08 | [Homepage Dashboard](./08-homepage-dashboard/) | ✅ Complete | Self-hosted services, YAML config |
| 09 | [Cyber Lab (AD + victims + attacker)](./09-cyber-lab/) | ✅ Complete | Active Directory, isolated lab design |
| 10 | [Suricata IDS](./10-suricata-ids/) | ✅ Complete | Network intrusion detection, ET rulesets |
| 11 | [OpenVAS Scanner](./11-openvas-scanner/) | ✅ Complete | Vulnerability management, Docker-in-LXC |
| 12 | [Attack Exercises](./12-attack-exercises/) | 🔄 In Progress | Kerberoasting, Pass-the-Hash, IR reports |

Every section contains:
- **README.md** — what was built, why, and the design decisions
- **COMMANDS.md** — every command used, why it was used, and where it was learned
- **ISSUES.md** — every problem encountered: symptom, root cause, investigation commands, fix, lesson learned

---

## Key Skills Demonstrated

**Networking** — VLAN segmentation (802.1Q trunk/access), default-deny firewall design, cross-VLAN routing and outbound NAT, recursive DNS architecture

**Security Operations** — SIEM deployment with custom detection rules mapped to MITRE ATT&CK, network IDS, vulnerability scanning, incident documentation

**Infrastructure** — Proxmox VE hypervisor, LXC containers and KVM VMs, Docker (including Docker-inside-LXC), mesh VPN with subnet routing

**Active Directory** — Windows Server 2022 domain controller, users/OUs/service accounts, SPN registration, domain joins

**Troubleshooting** — 35+ real, documented issues with root cause analysis: packet captures, ARP debugging, hardware failures, driver incompatibilities

---

## Hardware

| Device | Role |
|--------|------|
| GL.iNet Slate 7 | WAN entry router (DMZ mode) |
| Dell OptiPlex 7040 MFF Computer i5-6500T | pfSense firewall appliance |
| Dell OptiPlex 7040 MFF Computer i5-6500T (upgraded 500GB SSD) | Proxmox VE hypervisor |
| Netgear GS308E | Managed switch (Advanced 802.1Q) |

---

## Build Journal

See [build-journal/BUILD-JOURNAL.md](./build-journal/BUILD-JOURNAL.md) — the honest log: time planned vs. time actually spent, what each step taught, and why each component was chosen, with references.

---

## Contact

**Anton Leslie** · Calumet City, IL
GitHub: [github.com/AntonLesl](https://github.com/AntonLesl) · LinkedIn: [linkedin.com/in/antonleslie](https://linkedin.com/in/antonleslie)

*CompTIA Security+ | B.S. Computer Science, Cybersecurity Emphasis*
