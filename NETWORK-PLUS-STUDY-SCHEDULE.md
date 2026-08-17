# 📅 Network+ (N10-009) Study Schedule — Aug 17 to Sep 13, 2026

Built from two sources: the **Full Learning Guide (N10-009)** PDF you uploaded (page references below), and **Professor Messer's free N10-009 video course** — [professormesser.com/network-plus/n10-009/n10-009-video/n10-009-training-course](https://www.professormesser.com/network-plus/n10-009/n10-009-video/n10-009-training-course/) (87 videos, ~13 hours total, free).

> **Note on numbering:** the PDF guide groups topics slightly differently than Messer's official objective numbers (e.g. the guide's "1.5 Common Network Services" covers DHCP/DNS, which Messer files under his own 3.4). Don't worry about matching section numbers between the two — this schedule pairs them by topic, not number.
>
> **Gap the guide doesn't cover:** subnetting math and cabling/transmission-media details aren't broken out as their own sections in the PDF, but both are heavily tested. This schedule threads in dedicated subnetting practice every few days using Messer's videos directly, since it's a drilled skill, not a one-read topic.

Follows the existing weekly rhythm from `DAILY-STUDY-PLAN.md`: Mon/Thu = new material, Tue = practice questions, Wed = hands-on lab, Fri = timed practice, Sat = portfolio, Sun = light review.

---

## Week 1 (Aug 17–23) — Domain 1: Networking Concepts (23%)

| Day | Focus | Guide pages | Professor Messer videos |
|---|---|---|---|
| Mon 17 | OSI Model & Encapsulation, Networking Hardware | pp. 3–7 | Understanding the OSI Model (13:51) · Networking Devices (14:31) · Networking Functions (13:25) |
| Tue 18 | Quiz OSI/devices + **start subnetting** | — | Binary Math (9:15) · IPv4 Addressing (11:06) |
| Wed 19 | Hands-on: map every homelab device to its OSI layer + 10 subnetting problems | — | — |
| Thu 20 | Cloud Concepts, Common Protocols | pp. 7–9 | Designing the Cloud (9:49) · Cloud Models (5:23) · Introduction to IP (14:10) · Common Ports (20:22) · Other Useful Protocols (8:26) |
| Fri 21 | Timed: memorize the port table cold + 10 more subnetting problems | p. 9 | — |
| Sat 22 | Portfolio: journal entry | — | — |
| Sun 23 | Light review + preview | — | Classful Subnetting (10:58) · IPv4 Subnet Masks (9:00) |

## Week 2 (Aug 24–30) — finish Domain 1

| Day | Focus | Guide pages | Professor Messer videos |
|---|---|---|---|
| Mon 24 | Common Network Services (DHCP/DNS/NAT), Traffic Types | pp. 9–11 | DHCP (8:51) · An Overview of DNS (16:54) · DNS Records (9:04) |
| Tue 25 | Quiz DORA/DNS records/traffic types + subnetting | — | Calculating IPv4 Subnets and Hosts (9:46) |
| Wed 26 | Hands-on: Wireshark/tcpdump a DHCP lease + DNS query on the lab VLAN; ID the DORA packets live + 10 more subnetting problems | — | — |
| Thu 27 | Topologies & Network Types, Emerging Tech — **Domain 1 core content done** | pp. 11–13 | Network Topologies (4:42) · Network Architectures (4:53) · Software Defined Networking (6:56) · Zero Trust (6:41) · Infrastructure as Code (8:20) |
| Fri 28 | Timed: full Domain 1 practice set + pick a subnetting shortcut and drill it | — | Magic Number Subnetting (21:09) *or* Seven Second Subnetting (17:03) — pick whichever clicks |
| Sat 29 | Portfolio: log Domain 1 complete | — | — |
| Sun 30 | Light review Domain 1, preview Domain 2 | — | — |

## Week 3 (Aug 31–Sep 6) — Domain 2: Network Implementation (20%)

| Day | Focus | Guide pages | Professor Messer videos |
|---|---|---|---|
| Mon 31 | Routing Technologies & Bandwidth Mgmt | pp. 14–17 | Static Routing (7:21) · Dynamic Routing (9:12) · Routing Technologies (16:10) |
| Tue Sep1 | Quiz Administrative Distance values + routing protocol types + subnetting | — | — |
| Wed Sep2 | Hands-on: review your pfSense routing table; add/remove a static route, verify with traceroute | — | — |
| Thu Sep3 | Switching Technologies, Wireless Technologies | pp. 17–22 | VLANs and Trunking (12:29) · Spanning Tree Protocol (6:06) · Wireless Technologies (8:34) · Wireless Encryption (3:23) — optional depth: Copper Cabling (7:21), Fiber Connectors (3:56) |
| Fri Sep4 | Timed: Domain 2 drill (VLAN/trunk/STP scenarios, wireless standards, WPA2 vs WPA3) | — | — |
| Sat Sep5 | Portfolio: compare your managed switch's real VLAN/trunk config against the guide, note gaps | — | — |
| Sun Sep6 | Light review Domain 2, preview Domain 3 | — | — |

## Week 4 (Sep 7–13) — Domain 3 + 4 + 5, full review

| Day | Focus | Guide pages | Professor Messer videos |
|---|---|---|---|
| Mon 7 | Remaining Domain 2 services/topologies, Org Processes & Policies — **Domain 2 done** | pp. 22–31 | Configuring DHCP (10:18) · Time Protocols (5:02) · Network Documentation (10:42) · Life Cycle Management (8:17) · Configuration Management (5:19) |
| Tue 8 | Quiz documentation types, SLAs, change mgmt steps | — | — |
| Wed 9 | Hands-on: update your homelab's network diagram in `diagrams/` (real portfolio deliverable) | — | — |
| Thu 10 | Stats & Sensors, Disaster Recovery/HA, Remote Access — **Domain 3 done** | pp. 31–39 | SNMP (8:58) · Logs and Monitoring (13:06) · Disaster Recovery (12:09) · Network Redundancy (4:06) · VPNs (6:54) · Remote Access (7:52) |
| Fri 11 | Timed: Domain 3 drill (SNMP/Syslog/SIEM, RPO/RTO/MTTR/MTBF, VPN protocols) | — | — |
| Sat 12 | Security Concepts, Attack Types, Hardening & Auth — **Domain 4 done**. Apply the p.46 hardening checklist to one real homelab device | pp. 40–49 | Security Concepts (13:06) · Authentication (12:46) · Denial of Service (6:58) · ARP and DNS Poisoning (7:28) · Social Engineering (10:56) · Malware (6:41) · Device Security (9:03) · Security Rules (10:23) |
| Sun 13 | All of Domain 5 (Troubleshooting) — **Domain 5 done** — then a full timed 90-question practice exam, review every miss against the Domain summaries (pp. 13/27/39/50/61) and glossary (pp. 62–71) | pp. 51–61 | Network Troubleshooting Methodology (8:04) · Cable Issues (14:40) · Interface Issues (9:29) · Switching Issues (9:58) · Routing and IP Issues (9:37) · Performance Issues (7:18) · Wireless Issues (9:21) · Command Line Tools (17:59) |

---

## Why the last weekend is heavier

Domain 5 (Troubleshooting) is the single biggest exam weight (24%), but it's mostly *applying* concepts from Domains 1–4 rather than brand-new material, so it moves faster than a first encounter. If Sat 12/Sun 13 feels rushed, it's fine to let the practice exam slip to the following Monday — the roadmap already treats these dates as estimates, not deadlines.

## Ongoing thread: subnetting

Subnetting isn't a one-time read — it's a drilled skill. Short 10-problem sessions are worked in every few days above (Tue/Wed of weeks 1–3). Keep going until you can subnet in well under a minute per problem; that speed is what the "Magic Number" or "Seven Second" method (Week 2, Friday) is for.
