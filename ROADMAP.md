<p align="center">
  <img src="./assets/hero-banner.png" alt="Anton Leslie" width="100%">
</p>

<h1 align="center">🗺️ Certification Roadmap</h1>

<p align="center"><b>Anton Leslie</b> · Last updated: August 17, 2026</p>

> This is the map of where I've been and where I'm headed — from Security+ toward broad, real-world capability across networking, systems, and security. Every stop on this map is backed by hands-on work in the [homelab](./README.md) above, not just an exam voucher.

![Roadmap Progress](https://img.shields.io/badge/Roadmap%20Progress-1%2F7%20Certs%20Earned-c97a53?labelColor=1a0a0a)
![Current Focus](https://img.shields.io/badge/Currently%20Studying-CompTIA%20Network%2B-ffc9a8?labelColor=1a0a0a)
![Target Role](https://img.shields.io/badge/Open%20To-IT%20%2F%20Networking%20%2F%20Security%20Roles-c97a53?labelColor=1a0a0a)

---

## 🎯 Where This Is Headed

Broad, real-world capability across networking, systems administration, and security — not a bet on one narrow title. Each cert earns a real, transferable skill, and the order is built to compound: networking depth first (Network+ into CCNA, while it's freshest), then a quick Linux win, then cloud fundamentals, with Microsoft SC-300 and Okta rounding things out with dedicated identity-platform experience. Useful everywhere it could lead — SOC analyst, security engineer, systems/network admin, or identity-focused roles.

---

## 🧗 The Skill Path

```mermaid
flowchart TD
    A["✅ CompTIA Security+<br/>EARNED"]:::done --> B["🔄 CompTIA Network+<br/>IN PROGRESS"]:::active
    B --> C["🌐 Cisco CCNA"]:::planned
    C --> D["🐧 Linux Essentials"]:::planned
    D --> E["☁️ AWS Certified<br/>Cloud Practitioner"]:::planned
    E --> F["🔑 Microsoft SC-300<br/>Identity &amp; Access Admin"]:::planned
    F --> G["🛡️ Okta Certified<br/>Professional"]:::planned
    G --> H(["🎯 Continued Growth"]):::target

    classDef done fill:#c97a53,stroke:#7a4a30,color:#0a0a0a,font-weight:bold
    classDef active fill:#ffc9a8,stroke:#8a5c3e,color:#0a0a0a,font-weight:bold
    classDef planned fill:#1c1611,stroke:#3a2f26,color:#e9ddc8
    classDef target fill:#0a0a0a,stroke:#ffc9a8,color:#ffc9a8,font-weight:bold,stroke-width:2px
```

**Legend:** 🟤 Earned &nbsp;·&nbsp; 🍑 In progress &nbsp;·&nbsp; ⚫ Planned &nbsp;·&nbsp; ⬛ Ongoing

---

## 📅 Timeline

```mermaid
gantt
    title Certification Roadmap — Aug 2026 to Feb 2027 (~6 months)
    dateFormat YYYY-MM-DD
    axisFormat %b %Y
    todayMarker on

    section Foundation
    Security+ (earned)                 :done, sec, 2026-01-01, 2026-08-16
    Network+ (in progress)             :active, net, 2026-08-17, 2026-09-13

    section Build
    Cisco CCNA                         :ccna, 2026-09-14, 2026-11-22
    Linux Essentials                   :linux, 2026-11-23, 2026-12-06
    AWS Cloud Practitioner             :aws, 2026-12-07, 2026-12-27

    section Identity Platforms
    Microsoft SC-300                   :sc300, 2026-12-28, 2027-01-24
    Okta Certified Professional        :okta, 2027-01-25, 2027-02-14
```

*Dates are a planning estimate, not a deadline — the point is momentum, not a race. Adjust as real life happens.*

---

## 🧩 The Order, and Why

| # | Cert | Status | Window | Why it's here and not somewhere else |
|---|------|--------|--------|----------------------------------------|
| 1 | **CompTIA Security+** | ✅ Earned | — | The baseline — CIA triad, risk, threats, controls. Everything else builds on it. |
| 2 | **CompTIA Network+** | 🔄 In progress | Aug 17 – Sep 13 | You can't secure a network you don't understand. Direct payoff already: VLANs, NAT, and firewall rules in the homelab match this material 1:1. |
| 3 | **Cisco CCNA** | ⬜ Next | Sep 14 – Nov 22 | Right after Network+ while routing, switching, and subnetting are freshest — deepens networking immediately instead of letting momentum go cold on unrelated material first. |
| 4 | **Linux Essentials** | ⬜ Planned | Nov 23 – Dec 6 | A fast, lower-stakes win after the CCNA marathon — formalizes skills already in daily use: Wazuh, pfSense, Pi-hole, and Kali all run on Linux. |
| 5 | **AWS Certified Cloud Practitioner** | ⬜ Planned | Dec 7 – Dec 27 | The shortest, most foundational cloud cert — seeds the vocabulary (IAM, roles, policies) that SC-300 later goes deep on, without requiring hands-on AWS infra first. |
| 6 | **Microsoft SC-300** (Identity & Access Administrator) | ⬜ Planned | Dec 28 – Jan 24 | Builds directly on the homelab's Windows Server 2022 AD domain controller and on-the-job Entra ID / Intune experience — formalizes skills already in use. |
| 7 | **Okta Certified Professional** | ⬜ Planned | Jan 25 – Feb 14 | The capstone: a dedicated, market-leading identity platform. Comes last because SC-300 builds the identity *concepts* (federation, SSO, conditional access, provisioning) that Okta's platform-specific exam then applies. |

---

## 🔗 How the Homelab Already Backs This Up

| Cert target | Already demonstrated in this repo |
|---|---|
| Network+ / CCNA | [`02-pfsense-firewall`](./02-pfsense-firewall/), [`03-managed-switch`](./03-managed-switch/) — real 802.1Q VLAN trunking, firewall rule design, NAT |
| Linux Essentials | [`07-wazuh-siem`](./07-wazuh-siem/), [`05-pihole-dns`](./05-pihole-dns/), [`09-cyber-lab`](./09-cyber-lab/) — Linux services deployed, configured, and troubleshot from scratch |
| AWS CCP / cloud identity | Entra ID + Intune administration (500+ users, per [`RESUME.md`](./RESUME.md)) — direct analog to cloud IAM concepts |
| SC-300 | [`09-cyber-lab/active-directory-setup`](./09-cyber-lab/active-directory-setup/) — Windows Server 2022 AD DC, OUs, service accounts, SPNs, domain joins |
| Okta Certified Professional | Same AD/identity foundation, extended to a dedicated platform — the natural next lab addition once SC-300 is underway |

---

## ✅ How to Read This Roadmap

- 🟢 **Earned** — exam passed, cert active
- 🟠 **In progress** — actively studying right now
- ⬜ **Planned** — next in the queue, order is deliberate (see table above)
- Each phase gets a **daily study nudge** — see [`DAILY-STUDY-PLAN.md`](./DAILY-STUDY-PLAN.md) for the weekly rhythm behind it.

---

*This roadmap is a living document — status badges and the timeline get updated as certs are completed. Full build details and troubleshooting logs live in the main [README](./README.md) and [BUILD-JOURNAL.md](./build-journal/BUILD-JOURNAL.md).*
