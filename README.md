# Enterprise Homelab Portfolio

**Anton Leslie** — IT Systems Administrator | CompTIA Security+ | B.S. Computer Science (Cybersecurity Emphasis, Boise State — NSA/DHS CAE-CD)

A complete enterprise-grade network, security monitoring stack, and isolated attack lab built from scratch on physical hardware. Every section documents what was built, every command used (with references), and every problem hit along the way with its root cause and fix.

> **Note on sanitization:** All internal IP addresses, hostnames of note, and credentials are deliberately omitted or replaced with placeholders like `[firewall LAN IP]`. This repository is public.

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
| Lenovo ThinkCentre M60E | pfSense firewall appliance |
| Lenovo ThinkCentre (upgraded 500GB SSD) | Proxmox VE hypervisor |
| Netgear GS308E | Managed switch (Advanced 802.1Q) |

---

## Build Journal

See [build-journal/BUILD-JOURNAL.md](./build-journal/BUILD-JOURNAL.md) — the honest log: time planned vs. time actually spent, what each step taught, and why each component was chosen, with references.

---

## Contact

**Anton Leslie** · Calumet City, IL
GitHub: [github.com/AntonLesl](https://github.com/AntonLesl) · LinkedIn: [linkedin.com/in/antonleslie](https://linkedin.com/in/antonleslie)

*CompTIA Security+ | B.S. Computer Science, Cybersecurity Emphasis*
