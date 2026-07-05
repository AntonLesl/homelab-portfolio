# Homelab Build Journal

**Author:** Anton Leslie
**Purpose:** An honest, chronological log of building this homelab from scratch — how long each step actually took, why each component was chosen, what I learned, and every real issue I hit. The gap between planned and actual time is deliberate: it's the record of real troubleshooting, which is the whole point of building a lab instead of reading about one.

> All internal IPs, hostnames, and credentials are omitted — this repo is public.

---

## Time: Planned vs. Actual

| Step | Component | Planned | Actual | Why the difference |
|------|-----------|---------|--------|--------------------|
| 01 | Slate 7 WAN | 30 min | 40 min | Wrong network for admin access |
| 02 | pfSense firewall | 2 hrs | 5 hrs | Wrong image, Secure Boot, single NIC, NVMe incompatibility, disk selection, VLAN overlap |
| 03 | Managed switch | 1 hr | 3 hrs | Basic vs Advanced 802.1Q, multiple factory resets |
| 04 | Proxmox VE | 1 hr | 2 hrs | BIOS reset (dead CMOS), NVMe issues, new SSD |
| 05 | Pi-hole + Unbound | 1 hr | 2 hrs | cloudflared removed, double-tagging, cross-VLAN DNS |
| 06 | Tailscale VPN | 45 min | 1.5 hrs | accept-routes broke routing, IP forwarding not persisted |
| 07 | Wazuh SIEM | 2 hrs | 3 hrs | Interrupted install, upstream NIC flapping |
| 08 | Homepage dashboard | 30 min | 1 hr | Self-signed cert + wrong port |
| 09 | Cyber lab (AD) | 3 hrs | 4.5 hrs | VirtIO drivers, PowerShell continuation, no DHCP, disabled users |
| 10 | Suricata IDS | 1 hr | 2 hrs | IPS-on-WAN froze network, offloading, rule categories |
| 11 | OpenVAS scanner | 2 hrs | 4 hrs | Dead helper script, no Docker, disk full x3, overlay in LXC, nginx binding |
| **Total** | | **~15 hrs** | **~28.5 hrs** | Real-world troubleshooting |

---

## Step-by-Step: What, Why, and What I Learned

### 01 — GL.iNet Slate 7 (WAN entry)
**Why:** DMZ mode forwards all inbound traffic to pfSense so there's no double-NAT and the firewall sees real source IPs.
**Learned:** You can only reach an appliance's admin portal from its own subnet — check `ipconfig` before assuming a device is dead.
**Ref:** https://docs.gl-inet.com/

### 02 — pfSense CE Firewall
**Why:** A dedicated, single-purpose firewall keeps the security boundary independent of the hypervisor. pfSense CE gives enterprise features (VLANs, NAT, IDS, syslog) for free.
**Learned:** Match installer image to media; disable Secure Boot for non-Windows media; confirm NIC count before buying hardware; not all NVMe works with FreeBSD; confirm the install target by size; plan VLAN/IP addressing before the wizard.
**Ref:** https://docs.netgate.com/pfsense/en/latest/

### 03 — Netgear GS308E Managed Switch
**Why:** Carrying two segments (trusted + lab) over one trunk to the firewall requires 802.1Q tagging, which needs a managed switch.
**Learned (the big one):** GS308E **Basic** 802.1Q mode tags access-port egress, which ordinary NICs drop — it broke all ethernet. **Advanced** 802.1Q with explicit Tagged trunk + Untagged access ports and matching PVIDs is required. Create VLANs before assigning ports.
**Ref:** https://www.netgear.com/support/product/gs308e/

### 04 — Proxmox VE
**Why:** Free Type-1 hypervisor with great LXC + KVM support and bridge networking that makes a no-uplink isolated lab trivial.
**Learned:** Replace dead CMOS batteries on always-on boxes; give the hypervisor a roomy SSD; a NIC swap changes the MAC and invalidates peers' ARP caches (fixed with a permanent ARP entry).
**Ref:** https://pve.proxmox.com/wiki/

### 05 — Pi-hole + Unbound
**Why:** Network-wide DNS filtering plus recursive resolution from the root servers — privacy without depending on a public resolver.
**Learned:** cloudflared was removed in 2026.2.0 (Unbound is the recommended replacement); tag in only one place (double-tagging killed the container's internet); cross-VLAN DNS needs both `ListeningMode = "all"` and an outbound NAT rule.
**Ref:** https://docs.pi-hole.net/

### 06 — Tailscale VPN
**Why:** WireGuard-based mesh gives remote access with zero open WAN ports; subnet routing reaches internal services without installing Tailscale everywhere.
**Learned:** **Never** use `--accept-routes` on a subnet router (it broke local routing); persist `net.ipv4.ip_forward` in sysctl.conf or it resets on reboot.
**Ref:** https://tailscale.com/kb/1019/subnets/

### 07 — Wazuh SIEM
**Why:** One open-source platform for SIEM, HIDS, log analysis, and FIM — the tooling a SOC analyst actually uses. Six custom rules mapped to MITRE ATT&CK.
**Learned:** Don't run long installs on a box with a dead CMOS battery; a SIEM is only as reliable as the network under it — fix infra stability first.
**Ref:** https://documentation.wazuh.com/

### 08 — Homepage Dashboard
**Why:** A single pane of glass over every service once the lab outgrew remembering URLs and ports.
**Learned:** Internal services use self-signed certs (tell the dashboard to accept them); keep a record of each service's real management port.
**Ref:** https://gethomepage.dev/

### 09 — Isolated Cyber Lab (AD + victims + attacker)
**Why:** To practice attacks safely you need a realistic domain target on a bridge with no uplink, so offensive traffic can never reach the real network.
**Learned:** Have the VirtIO driver ISO ready for Windows on Proxmox; PowerShell line continuation is finicky; an isolated bridge needs a deliberate static-IP plan (no DHCP by design); new AD accounts must be enabled and meet password policy.
**Ref:** https://learn.microsoft.com/windows-server/identity/ad-ds/

### 10 — Suricata IDS
**Why:** Network intrusion detection over internal traffic, feeding alerts into the monitoring workflow.
**Learned:** IPS mode inline on the WAN froze the network on this hardware — IDS (alert) mode on the LAN is the right call until a PCIe NIC exists; disable hardware offloading so the engine inspects real packets; enable rule categories deliberately or you get either silence or noise.
**Ref:** https://docs.netgate.com/pfsense/en/latest/packages/suricata/index.html

### 11 — OpenVAS / Greenbone
**Why:** Continuous vulnerability scanning of my own infrastructure — the vuln-management loop a real program runs.
**Learned:** Community helper scripts disappear (fall back to the vendor's official install); size the scanner's disk generously (feed + images are huge); Docker-in-LXC needs a privileged container with nesting/keyctl/fuse + unconfined AppArmor; check what interface a service binds to.
**Ref:** https://greenbone.github.io/docs/

### 12 — Attack Exercises & IR (in progress)
**Why:** The purple-team payoff — run techniques from Kali, detect them in Wazuh/Suricata, and document each as an incident report with the MITRE technique and response.
**Learned:** (logged per-exercise as they're completed.)
**Ref:** https://attack.mitre.org/

---

## Components Used (with references)

| Component | Role | Reference |
|-----------|------|-----------|
| GL.iNet Slate 7 | WAN entry router (DMZ) | https://docs.gl-inet.com/ |
| pfSense CE | Firewall / router / VLANs / NAT | https://docs.netgate.com/pfsense/ |
| Lenovo ThinkCentre M60E | pfSense hardware | — |
| Netgear GS308E | Managed switch (802.1Q) | https://www.netgear.com/support/product/gs308e/ |
| Proxmox VE | Type-1 hypervisor | https://pve.proxmox.com/wiki/ |
| Pi-hole | Network-wide DNS filtering | https://docs.pi-hole.net/ |
| Unbound | Recursive DNS resolver | https://docs.pi-hole.net/guides/dns/unbound/ |
| Tailscale | Mesh VPN (WireGuard) | https://tailscale.com/kb/ |
| Wazuh | SIEM / XDR / HIDS | https://documentation.wazuh.com/ |
| Homepage | Service dashboard | https://gethomepage.dev/ |
| Windows Server 2022 | Active Directory DC | https://learn.microsoft.com/windows-server/ |
| Windows 10 | Domain-joined victim | — |
| Kali Linux | Attacker platform | https://www.kali.org/docs/ |
| Metasploitable 2 | Vulnerable target | https://docs.rapid7.com/metasploit/metasploitable-2/ |
| Suricata | Network IDS | https://docs.suricata.io/ |
| Greenbone / OpenVAS | Vulnerability scanner | https://greenbone.github.io/docs/ |
| nmap | Network scanning | https://nmap.org/book/ |
| impacket | AD attack tooling | https://github.com/fortra/impacket |
| MITRE ATT&CK | Detection mapping framework | https://attack.mitre.org/ |

---

## Recurring Hardware Themes

1. **USB LAN adapter flapping** on pfSense — the single biggest reliability drag. Worked around with adapter swaps and reboot/reload crons; **permanent fix is an Intel I210-T1 PCIe x1 NIC**.
2. **Dead CMOS battery** on the ThinkCentre — BIOS resets on power loss; needs the battery replaced.
3. **NIC MAC changes** cascading into ARP failures on Proxmox — fixed with a permanent ARP entry, ultimately solved by the PCIe NIC.

The through-line: **cheap USB networking is fine for a bench but not for anything always-on.** The permanent fix identified throughout is a proper PCIe Intel NIC.
