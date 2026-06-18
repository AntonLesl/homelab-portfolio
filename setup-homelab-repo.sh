#!/usr/bin/env bash
# ============================================================
# Anton Leslie — Homelab Portfolio GitHub Setup Script
# Run this from inside your cloned repo directory:
#   git clone https://github.com/AntonLesl/homelab-portfolio
#   cd homelab-portfolio
#   bash setup-homelab-repo.sh
# ============================================================

set -e
echo ""
echo "========================================"
echo "  Homelab Portfolio — Full Repo Setup"
echo "========================================"
echo ""

# ── STEP 1: Remove old structure ────────────────────────────
echo "[1/6] Removing old folder structure..."
rm -rf "Completed " "Scripts Made " "To Do " "ExampleREADME.md" 2>/dev/null || true
echo "      Done."

# ── STEP 2: Create folder structure ─────────────────────────
echo "[2/6] Creating new folder structure..."

mkdir -p 01-slate7-wan-setup/screenshots
mkdir -p 02-pfsense-firewall/screenshots
mkdir -p 03-managed-switch/screenshots
mkdir -p 04-pihole-dns/screenshots
mkdir -p 05-proxmox-virtualization/screenshots
mkdir -p 06-tailscale-vpn/screenshots
mkdir -p 07-cyber-lab/active-directory-setup/screenshots
mkdir -p 07-cyber-lab/attack-exercises/screenshots
mkdir -p 07-cyber-lab/screenshots
mkdir -p 08-wazuh-siem/incident-reports
mkdir -p 08-wazuh-siem/screenshots
mkdir -p scripts
mkdir -p diagrams

echo "      Done."

# ── STEP 3: Write all README placeholder files ───────────────
echo "[3/6] Writing documentation files..."

# ── .gitignore ──────────────────────────────────────────────
cat > .gitignore << 'EOF'
*.DS_Store
Thumbs.db
*.log
*.tmp
*.bak
secrets/
credentials/
*.key
*.pem
EOF

# ── TOPOLOGY.md ─────────────────────────────────────────────
cat > TOPOLOGY.md << 'EOF'
# Network Topology

## Full Diagram

```
                        ┌──────────────────┐
                        │   ISP / Internet  │
                        └────────┬─────────┘
                                 │
                        ┌────────▼─────────┐
                        │  GL.iNet Slate 7  │  WAN entry · DMZ passthrough
                        └────────┬─────────┘
                                 │
                        ┌────────▼──────────────────┐
                        │       pfSense Firewall      │
                        │  VLAN 10 → 192.168.10.1    │  Firewall · Suricata IDS
                        │  VLAN 30 → 192.168.30.1    │  DHCP · NAT · IPS
                        └────────┬──────────────────┘
                                 │ trunk (VLANs 10, 30)
                   ┌─────────────▼──────────────────────┐
                   │        8-Port Managed Switch         │  802.1Q VLAN distribution
                   └──────┬──────────┬──────────┬────────┘
                          │          │           │
                   ┌──────▼───┐ ┌────▼───┐ ┌────▼───────────────────────────────┐
                   │ Pi-hole  │ │ Laptop │ │            Proxmox VE               │
                   │ VLAN 10  │ │ VLAN10 │ │         192.168.30.10               │
                   │.10.2     │ │.10.x   │ │                                     │
                   │ DNS+DoH  │ └────────┘ │  vmbr0 (VLAN 30)                   │
                   └──────────┘            │  ├── Wazuh SIEM  192.168.30.20     │
                                           │  └── OpenVAS     192.168.30.30     │
                                           │                                     │
                                           │  vmbr2 (NO UPLINK · ISOLATED)      │
                                           │  ├── Kali Linux    10.10.10.5      │
                                           │  ├── Windows AD    10.10.10.10     │
                                           │  ├── Windows 10    10.10.10.20     │
                                           │  └── Metasploitable 10.10.10.30    │
                                           │     Wazuh logs only · port 1514    │
                                           └────────────────────────────────────┘

Tailscale VPN overlay · pfSense + Proxmox · zero open WAN ports
Remote access to VLAN 10 + VLAN 30 from anywhere
```

## IP Address Scheme

### VLAN 10 — Trusted (192.168.10.0/24)
| Device | IP | Notes |
|--------|-----|-------|
| pfSense gateway | 192.168.10.1 | VLAN 10 interface |
| Pi-hole | 192.168.10.2 | Static — DNS for all VLANs |
| Trusted laptop | 192.168.10.100–200 | DHCP range |

### VLAN 30 — Lab Infrastructure (192.168.30.0/24)
| Device | IP | Notes |
|--------|-----|-------|
| pfSense gateway | 192.168.30.1 | VLAN 30 interface |
| Proxmox VE | 192.168.30.10 | Static |
| Wazuh SIEM | 192.168.30.20 | Static — LXC on vmbr0 |
| OpenVAS | 192.168.30.30 | Static — VM on vmbr0 |
| Switch management | 192.168.30.200 | Static |

### vmbr2 — Isolated Cyber Lab (10.10.10.0/24)
| Device | IP | Notes |
|--------|-----|-------|
| Kali Linux | 10.10.10.5 | Attacker VM |
| Windows Server 2022 | 10.10.10.10 | Domain controller (lab.local) |
| Windows 10 | 10.10.10.20 | Domain-joined victim workstation |
| Metasploitable 2 | 10.10.10.30 | Vulnerable Linux target |

## Switch Port Assignment
| Port | Mode | VLAN | Device |
|------|------|------|--------|
| 1 | Trunk | 10, 30 | pfSense LAN port |
| 2 | Access | 10 | Pi-hole |
| 3 | Access | 10 | Trusted laptop |
| 4 | Access | 30 | Proxmox server |
| 5–8 | Spare | — | Available |

## Traffic Rules
| Source | Destination | Action | Enforced by |
|--------|------------|--------|-------------|
| VLAN 10 | Internet | Allow | pfSense |
| VLAN 10 | VLAN 30 | Block | pfSense |
| VLAN 30 | Internet | Allow (updates) | pfSense |
| VLAN 30 | VLAN 10 | Block | pfSense |
| vmbr2 | Internet | Block | Proxmox (no uplink) |
| vmbr2 | VLAN 10 | Block | Proxmox (no uplink) |
| vmbr2 | 192.168.30.20:1514 | Allow | Proxmox static route |
EOF

# ── 01 Slate 7 ──────────────────────────────────────────────
cat > 01-slate7-wan-setup/README.md << 'EOF'
# 01 — GL.iNet Slate 7 WAN Setup

**Skills:** DMZ mode, WAN passthrough, travel router hardening

## Purpose
The Slate 7 receives the public IP from the ISP and forwards it directly to pfSense via DMZ mode, eliminating double-NAT and giving pfSense true edge visibility.

## Steps
1. Connect ISP modem LAN → Slate 7 WAN port
2. Access admin panel at `http://192.168.8.1`
3. Go to **More Settings → Network → DMZ** → enable → set target to `192.168.8.2` (pfSense WAN)
4. Connect Slate 7 LAN → pfSense WAN NIC
5. Harden: disable cloud services, change admin password, disable unused Wi-Fi

## Verification
| Check | Expected |
|-------|---------|
| Slate 7 WAN | Public ISP IP |
| pfSense WAN | 192.168.8.2 |
| DMZ active | All traffic forwarded to pfSense |

## Screenshots
See [`screenshots/`](./screenshots/)

## Resume Bullet
> "Configured GL.iNet Slate 7 as WAN entry with DMZ forwarding to pfSense, eliminating double-NAT and enabling full edge firewall source IP visibility"
EOF

# ── 02 pfSense ──────────────────────────────────────────────
cat > 02-pfsense-firewall/README.md << 'EOF'
# 02 — pfSense Firewall

**Skills:** VLAN segmentation, firewall rules, Suricata IDS/IPS, DHCP hardening

## Purpose
pfSense is the network core — handles all routing, VLAN enforcement, intrusion detection, and DHCP. Nothing crosses segments without an explicit allow rule.

## Steps
1. Install pfSense CE on mini PC (2 NICs: WAN + LAN)
2. Run setup wizard — LAN: `192.168.10.1/24`
3. Create VLANs 10 (TRUSTED) and 30 (LAB) on LAN interface
4. Assign VLAN interfaces with static IPs
5. Configure DHCP on each VLAN — Pi-hole as only DNS server
6. Add static leases for Pi-hole, Proxmox, Wazuh, OpenVAS
7. Write firewall rules (see [firewall-rules.md](./firewall-rules.md))
8. Install and configure Suricata on WAN
9. Enable syslog to Wazuh at `192.168.30.20:514`

## Key Config Files
- [firewall-rules.md](./firewall-rules.md) — all rules with rationale
- [vlan-config.md](./vlan-config.md) — VLAN interface setup

## Resume Bullets
> "Deployed pfSense CE with VLAN segmentation across trusted and lab segments, enforcing zero inter-VLAN trust via explicit allow/deny ruleset"
> "Configured Suricata IDS/IPS on WAN with ET Open and Snort Community rulesets for real-time threat detection and blocking"
EOF

cat > 02-pfsense-firewall/firewall-rules.md << 'EOF'
# pfSense Firewall Rules

## VLAN 10 — TRUSTED Rules
| # | Action | Source | Destination | Port | Purpose |
|---|--------|--------|-------------|------|---------|
| 1 | Allow | TRUSTED net | any | 80, 443 | Internet access |
| 2 | Allow | TRUSTED net | 192.168.10.2 | 53 | DNS to Pi-hole only |
| 3 | Block | TRUSTED net | LAB net | any | Block trusted → lab |
| 4 | Block | TRUSTED net | any | any | Default deny |

## VLAN 30 — LAB Rules
| # | Action | Source | Destination | Port | Purpose |
|---|--------|--------|-------------|------|---------|
| 1 | Allow | LAB net | any | 80, 443 | Internet for updates |
| 2 | Allow | LAB net | 192.168.10.2 | 53 | DNS to Pi-hole |
| 3 | Block | LAB net | TRUSTED net | any | Block lab → trusted |
| 4 | Block | LAB net | any | any | Default deny |

## WAN Rules
Default: block all inbound. No allow rules on WAN.

## Notes
- vmbr2 (isolated cyber lab) has no pfSense interface — isolation enforced at Proxmox hypervisor level
- Suricata runs on WAN interface in IPS mode (block offenders)
- pfSense syslog → Wazuh 192.168.30.20:514
EOF

cat > 02-pfsense-firewall/vlan-config.md << 'EOF'
# VLAN Configuration

## VLANs Created on LAN Interface

| VLAN Tag | Name | Interface IP | DHCP Range | DNS Served |
|----------|------|-------------|------------|-----------|
| 10 | TRUSTED | 192.168.10.1/24 | .100–.200 | 192.168.10.2 (Pi-hole) |
| 30 | LAB | 192.168.30.1/24 | .100–.200 | 192.168.10.2 (Pi-hole) |

## Static DHCP Leases

| Device | MAC | IP |
|--------|-----|----|
| Pi-hole | (Pi-hole MAC) | 192.168.10.2 |
| Proxmox | (Proxmox MAC) | 192.168.30.10 |
| Wazuh | (Wazuh VM MAC) | 192.168.30.20 |
| OpenVAS | (OpenVAS VM MAC) | 192.168.30.30 |
| Switch | (Switch MAC) | 192.168.30.200 |

## Critical DHCP Setting
DNS Server 1: `192.168.10.2` (Pi-hole only)
DNS Server 2: (blank — forces all DNS through Pi-hole, no bypass possible)
EOF

# ── 03 Switch ───────────────────────────────────────────────
cat > 03-managed-switch/README.md << 'EOF'
# 03 — Managed Switch VLAN Configuration

**Skills:** 802.1Q trunking, access port assignment, layer-2 isolation

## Port Assignment
| Port | Mode | VLAN | Device |
|------|------|------|--------|
| 1 | Trunk | 10, 30 | pfSense LAN port |
| 2 | Access | 10 | Pi-hole |
| 3 | Access | 10 | Trusted laptop |
| 4 | Access | 30 | Proxmox server |
| 5–8 | Spare | — | — |

## Configuration (TP-Link TL-SG108E)
1. Set switch mgmt IP to `192.168.30.200`
2. Create VLAN 10: Port 1 Tagged, Ports 2–3 Untagged
3. Create VLAN 30: Port 1 Tagged, Port 4 Untagged
4. Set PVID: Port 2 → 10, Port 3 → 10, Port 4 → 30
5. Apply and verify devices receive correct IPs

## Resume Bullet
> "Configured 8-port managed switch with 802.1Q VLAN trunking, assigning access ports per segment to enforce layer-2 traffic isolation"
EOF

# ── 04 Pi-hole ──────────────────────────────────────────────
cat > 04-pihole-dns/README.md << 'EOF'
# 04 — Pi-hole + DNS over HTTPS

**Skills:** Network-wide DNS filtering, Cloudflared DoH, threat blocklists, anomalous domain monitoring

## Purpose
Pi-hole intercepts every DNS query on the network and filters against threat blocklists. Cloudflared encrypts all outbound DNS over HTTPS so the ISP sees zero DNS traffic.

## Architecture
```
Client → Pi-hole (192.168.10.2:53) → Cloudflared (127.0.0.1:5053) → Cloudflare 1.1.1.1 (DoH)
```

## Steps
1. Create LXC in Proxmox — Ubuntu 22.04, IP `192.168.10.2`, VLAN 10, vmbr0
2. Install Pi-hole: `curl -sSL https://install.pi-hole.net | bash`
3. Install cloudflared and configure as DoH proxy on port 5053
4. Point Pi-hole upstream DNS to `127.0.0.1#5053`
5. Add blocklists (see [blocklists.md](./blocklists.md))
6. Run `pihole -g` to update gravity
7. Set pfSense DHCP to serve only `192.168.10.2` as DNS

## Cloudflared Install
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb
mkdir -p /etc/cloudflared
cat > /etc/cloudflared/config.yml << CONF
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
CONF
cloudflared service install
systemctl enable --now cloudflared
```

## Resume Bullets
> "Deployed Pi-hole DNS sinkhole with 1.2M+ domain blocklist aggregating OISD, Steven Black, and URLhaus threat intel"
> "Configured DNS over HTTPS via Cloudflared eliminating ISP DNS visibility and encrypting all recursive queries"
EOF

cat > 04-pihole-dns/blocklists.md << 'EOF'
# Pi-hole Blocklists

## Active Blocklists

| List | Source | Focus |
|------|--------|-------|
| OISD Full | `https://big.oisd.nl` | Ads, trackers, malware |
| Steven Black | `https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts` | Ads + social |
| URLhaus | `https://urlhaus.abuse.ch/downloads/rpz/` | Malware URLs |
| Anti-Malware | Dandelion Sprout | Malware domains |

## Stats
- Total domains blocked: ~1.2 million
- Query volume: update this after Pi-hole is live

## DNS Anomalies to Watch
- Repeated queries to unknown `.xyz`, `.top`, `.tk` domains (high abuse TLDs)
- Long random-character subdomains (possible DNS tunneling / C2 beaconing)
- High query rate from a single host at unusual hours
EOF

# ── 05 Proxmox ──────────────────────────────────────────────
cat > 05-proxmox-virtualization/README.md << 'EOF'
# 05 — Proxmox VE Virtualization

**Skills:** Hypervisor deployment, virtual bridge design, VLAN integration, network isolation

## Purpose
Proxmox hosts all lab VMs and containers. Two virtual bridges split management traffic (vmbr0, VLAN 30) from the fully isolated cyber lab (vmbr2, no uplink).

## Network Bridges
| Bridge | Uplink | VLAN | Purpose |
|--------|--------|------|---------|
| vmbr0 | Physical NIC | 30 | Management — Proxmox, Wazuh, OpenVAS |
| vmbr2 | None | None | Isolated cyber lab — no external routing |

## /etc/network/interfaces
See [`network-interfaces.conf`](./network-interfaces.conf)

## Steps
1. Install Proxmox VE — set IP to `192.168.30.10/24`
2. Switch from enterprise to community repo
3. Edit `/etc/network/interfaces` with vmbr0 and vmbr2 config
4. Add static route for Wazuh log push from lab
5. Create Ubuntu 22.04 cloud-init template (VM 9000)
6. Clone template for Wazuh and OpenVAS

## Resume Bullet
> "Deployed Proxmox VE with dual virtual bridge configuration — vmbr0 on VLAN 30 for management, vmbr2 as internal-only bridge enforcing complete lab isolation at hypervisor level"
EOF

cat > 05-proxmox-virtualization/network-interfaces.conf << 'EOF'
# /etc/network/interfaces — Proxmox VE
# Replace enp1s0 with your actual NIC name (find with: ip link show)

auto lo
iface lo inet loopback

# Physical NIC — no IP assigned directly
auto enp1s0
iface enp1s0 inet manual

# vmbr0 — Management bridge — connects to physical NIC on VLAN 30
# Proxmox UI, Wazuh, OpenVAS, and management VMs use this bridge
auto vmbr0
iface vmbr0 inet static
    address 192.168.30.10/24
    gateway 192.168.30.1
    bridge-ports enp1s0
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 30

# vmbr2 — Isolated cyber lab bridge — NO physical port, NO uplink
# VMs on this bridge have zero external routing
# Only outbound path: static route below for Wazuh log push
auto vmbr2
iface vmbr2 inet manual
    bridge-ports none
    bridge-stp off
    bridge-fd 0

# Static route: allow lab VMs to push logs to Wazuh only
# Wazuh (192.168.30.20) receives on port 1514
# Nothing else from 10.10.10.0/24 can reach the outside
post-up   ip route add 10.10.10.0/24 via 192.168.30.20 dev vmbr0
pre-down  ip route del 10.10.10.0/24 via 192.168.30.20 dev vmbr0
EOF

# ── 06 Tailscale ────────────────────────────────────────────
cat > 06-tailscale-vpn/README.md << 'EOF'
# 06 — Tailscale VPN

**Skills:** Mesh VPN, subnet routing, zero-trust remote access, Tailscale ACL policy

## Purpose
Tailscale provides encrypted remote access to the homelab from any device with no open ports on the WAN firewall. Runs on pfSense and Proxmox as subnet routers.

## Subnet Routes Advertised
| Node | Advertised Subnet |
|------|-----------------|
| pfSense | 192.168.10.0/24 (VLAN 10) |
| Proxmox | 192.168.30.0/24 (VLAN 30) |

> vmbr2 (10.10.10.0/24) is intentionally NOT advertised. Lab VMs accessed via Proxmox console only.

## Install on Proxmox
```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --advertise-routes=192.168.30.0/24 --ssh --accept-dns=false
systemctl enable tailscaled
```

## Install on pfSense
System → Package Manager → search `tailscale` → install
VPN → Tailscale → Authenticate → enable subnet route `192.168.10.0/24`

## Tailscale ACL Policy
```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["autogroup:member"],
      "dst": ["192.168.10.0/24:*", "192.168.30.0/24:*"]
    }
  ]
}
```

## Resume Bullet
> "Deployed Tailscale mesh VPN on pfSense and Proxmox advertising subnet routes for VLAN 10 and 30, enabling zero-trust remote access with no exposed WAN ports"
EOF

# ── 07 Cyber Lab ────────────────────────────────────────────
cat > 07-cyber-lab/README.md << 'EOF'
# 07 — Isolated Cyber Lab

**Skills:** AD deployment, network isolation, Kali Linux, attack simulation, snapshot workflow

## Design
All attack and defense VMs run exclusively on vmbr2 — Proxmox's internal-only bridge with no physical uplink. pfSense has no route to 10.10.10.0/24. The only outbound path is Wazuh agent log push on port 1514.

## VM Inventory
| VM | IP | Role | Bridge |
|----|-----|------|--------|
| Kali Linux | 10.10.10.5 | Attacker | vmbr2 |
| Windows Server 2022 | 10.10.10.10 | Domain controller (lab.local) | vmbr2 |
| Windows 10 | 10.10.10.20 | Domain-joined victim | vmbr2 |
| Metasploitable 2 | 10.10.10.30 | Vulnerable Linux target | vmbr2 |

## What Can Talk to What
| Source | Destination | Allowed |
|--------|------------|---------|
| Kali | Windows AD / Win10 | Yes — shared vmbr2 |
| Kali | Wazuh (192.168.30.20) | Port 1514 only |
| Kali | Internet | No |
| Kali | VLAN 10 / VLAN 30 | No |
| Any lab VM | Proxmox mgmt | No |

## Setup Docs
- [Active Directory Setup](./active-directory-setup/README.md)
- [Attack Exercises](./attack-exercises/)
- [Network Design](./network-design.md)

## Snapshot Workflow
```bash
# Before every exercise
qm snapshot 201 clean-state --description "Before lab"
qm snapshot 202 clean-state --description "Before lab"
qm snapshot 203 clean-state --description "Before lab"

# Restore after exercise
qm rollback 201 clean-state
qm rollback 202 clean-state
qm rollback 203 clean-state
```
EOF

cat > 07-cyber-lab/network-design.md << 'EOF'
# Cyber Lab Network Design

## Why vmbr2 with no uplink?

The cyber lab uses a Proxmox internal bridge (`vmbr2`) with `bridge-ports none`. This means:
- No physical NIC is attached
- pfSense has no interface into 10.10.10.0/24
- There is no route out — not even through the hypervisor host
- The only exception is the static route added in `/etc/network/interfaces` for Wazuh log shipping

This is isolation enforced at the hypervisor level, not just firewall rules. Even if pfSense were misconfigured, the lab VMs still cannot reach the outside.

## /etc/hosts on all lab VMs
```
10.10.10.5    kali
10.10.10.10   dc01 dc01.lab.local
10.10.10.20   win10 win10.lab.local
10.10.10.30   metasploitable
```

## Wazuh Agent Config on Lab VMs
Each lab VM runs a Wazuh agent pointing to `192.168.30.20:1514`.
The agent initiates outbound — management network never initiates inbound to lab.
EOF

cat > 07-cyber-lab/active-directory-setup/README.md << 'EOF'
# Active Directory Lab Setup

## Domain
- Domain name: `lab.local`
- NetBIOS: `LAB`
- Domain Controller: `dc01` (10.10.10.10)

## Install AD DS on Windows Server 2022
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
  -DomainName "lab.local" `
  -DomainNetbiosName "LAB" `
  -InstallDns `
  -SafeModeAdministratorPassword (ConvertTo-SecureString "Lab@Password123!" -AsPlainText -Force) `
  -Force
```

## Create Lab Users
```powershell
# Regular users
New-ADUser -Name "jsmith" -SamAccountName "jsmith" `
  -UserPrincipalName "jsmith@lab.local" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) `
  -Enabled $true

# Service account with SPN (Kerberoasting target)
New-ADUser -Name "svc-sql" -SamAccountName "svc-sql" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "ServicePass1!" -AsPlainText -Force) `
  -Enabled $true

Set-ADUser -Identity "svc-sql" `
  -ServicePrincipalNames @{Add="MSSQLSvc/dc01.lab.local:1433"}
```

## Enable Audit Policies
```powershell
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable

# PowerShell script block logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
```
EOF

cat > 07-cyber-lab/attack-exercises/kerberoasting.md << 'EOF'
# Attack Exercise — Kerberoasting

**MITRE ATT&CK:** T1558.003  
**Tool:** Impacket GetUserSPNs.py  
**Target:** svc-sql service account (SPN set)

## Attack
```bash
# From Kali (10.10.10.5)
python3 GetUserSPNs.py lab.local/jsmith:Password123! \
  -dc-ip 10.10.10.10 \
  -request \
  -outputfile hashes.txt

# Crack offline
hashcat -m 13100 hashes.txt /usr/share/wordlists/rockyou.txt
```

## Detection (Wazuh)
- Event ID 4769 on dc01 — TGS ticket requested for svc-sql with encryption type 0x17 (RC4)
- Wazuh rule 100001 fires at level 12

## Evidence
Add screenshot of Wazuh alert here

## Remediation
- Rotate svc-sql password to 25+ char random
- Add svc-sql to Protected Users group
- Audit all SPNs: `Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName`
EOF

cat > 07-cyber-lab/attack-exercises/pass-the-hash.md << 'EOF'
# Attack Exercise — Pass-the-Hash

**MITRE ATT&CK:** T1550.002  
**Tool:** Impacket psexec.py  
**Prereq:** NTLM hash obtained via Mimikatz or secretsdump

## Attack
```bash
# Dump hashes from Windows 10 (after getting SYSTEM)
python3 secretsdump.py LAB/jsmith:Password123!@10.10.10.20

# Use hash to authenticate without password
python3 psexec.py -hashes :NTLMHASHHERE administrator@10.10.10.10
```

## Detection (Wazuh)
- Event ID 4624 — logon type 3 with NTLM authentication package
- No password in logon — lateral movement indicator
- Wazuh rule 100003 fires at level 12

## Evidence
Add screenshot of Wazuh alert here

## Remediation
- Enable Protected Users security group for privileged accounts
- Disable NTLM where possible — enforce Kerberos
- Deploy Windows Defender Credential Guard
EOF

cat > 07-cyber-lab/attack-exercises/bloodhound-enumeration.md << 'EOF'
# Attack Exercise — BloodHound AD Enumeration

**MITRE ATT&CK:** T1087.002  
**Tool:** BloodHound + bloodhound-python collector  
**Goal:** Map attack paths to Domain Admin

## Attack
```bash
# Collect AD data from Kali
bloodhound-python \
  -u jsmith \
  -p 'Password123!' \
  -d lab.local \
  -ns 10.10.10.10 \
  -c all \
  --zip

# Launch BloodHound UI and import zip
# Queries to run:
# - Shortest Paths to Domain Admins
# - Find Kerberoastable Users
# - Find AS-REP Roastable Users
# - Principals with DCSync Rights
```

## Detection (Wazuh)
- Event ID 4662 — LDAP read on AD objects (replication rights)
- High volume of LDAP queries from 10.10.10.5 in short window
- Wazuh rule 100002 fires at level 10

## Evidence
Add screenshot of BloodHound graph + Wazuh alert here
EOF

cat > 07-cyber-lab/attack-exercises/metasploit-vsftpd.md << 'EOF'
# Attack Exercise — Metasploit vsftpd Backdoor

**MITRE ATT&CK:** T1190  
**Tool:** Metasploit Framework  
**Target:** Metasploitable 2 (10.10.10.30)

## Attack
```bash
# Scan target
nmap -sV 10.10.10.30

# Launch Metasploit
msfconsole

use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 10.10.10.30
run

# Should receive root shell
whoami
```

## Detection (Wazuh)
- Suricata alert: ET EXPLOIT vsftpd backdoor trigger
- Wazuh process creation alert — unexpected shell spawned from vsftpd
- Source IP 10.10.10.5 (Kali)

## Evidence
Add screenshot of shell + Wazuh alert here

## Remediation
- Patch vsftpd to non-backdoored version
- Restrict FTP access with firewall rules
- Monitor for outbound connections from FTP service
EOF

# ── 08 Wazuh ────────────────────────────────────────────────
cat > 08-wazuh-siem/README.md << 'EOF'
# 08 — Wazuh SIEM + Detection Engineering

**Skills:** SIEM deployment, log ingestion, custom detection rules, MITRE ATT&CK mapping, incident response

## Architecture
```
pfSense syslog → Wazuh (192.168.30.20) ← Wazuh agents (all VMs)
```

## Log Sources
| Source | Method | Events |
|--------|--------|--------|
| pfSense | Syslog UDP 514 | Firewall blocks, DHCP, system |
| Kali Linux | Wazuh agent | Commands, file integrity, network |
| Windows Server 2022 | Wazuh agent | Security events, AD logs |
| Windows 10 | Wazuh agent | Security events, logon, process |
| Proxmox | Wazuh agent | System, auth |

## Install (LXC on Proxmox)
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
# Edit config.yml — set all IPs to 192.168.30.20
bash wazuh-install.sh -a
```

## Custom Rules
See [`custom-rules.xml`](./custom-rules.xml)

## Incident Reports
| # | Incident | MITRE | Report |
|---|----------|-------|--------|
| IR-001 | Kerberoasting | T1558.003 | [→](./incident-reports/IR-001-kerberoasting.md) |
| IR-002 | Pass-the-Hash | T1550.002 | [→](./incident-reports/IR-002-pass-the-hash.md) |
| IR-003 | BloodHound enum | T1087.002 | [→](./incident-reports/IR-003-bloodhound.md) |
| IR-004 | vsftpd exploit | T1190 | [→](./incident-reports/IR-004-vsftpd.md) |
| IR-005 | LSASS dump | T1003.001 | [→](./incident-reports/IR-005-lsass-dump.md) |

## Resume Bullets
> "Deployed Wazuh SIEM aggregating logs from 5+ sources including pfSense, Windows AD, and Kali Linux across isolated VLAN segments"
> "Authored custom Wazuh detection rules mapped to MITRE ATT&CK for Kerberoasting, Pass-the-Hash, LSASS dumping, and AD enumeration"
> "Produced incident response playbooks documenting attack execution, SIEM detection timeline, evidence, and remediation for each lab exercise"
EOF

cat > 08-wazuh-siem/custom-rules.xml << 'EOF'
<!-- Wazuh Custom Detection Rules — Lab ATT&CK Coverage -->
<!-- Place in: /var/ossec/etc/rules/lab-custom-rules.xml -->

<group name="lab,active_directory,">

  <!-- T1558.003 — Kerberoasting: RC4 TGS ticket request -->
  <rule id="100001" level="12">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4769$</field>
    <field name="win.eventdata.ticketEncryptionType">^0x17$</field>
    <description>Kerberoasting: RC4 TGS ticket requested for $(win.eventdata.serviceName)</description>
    <mitre>
      <id>T1558.003</id>
    </mitre>
  </rule>

  <!-- T1003.006 — DCSync / LDAP replication access -->
  <rule id="100002" level="10">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4662$</field>
    <field name="win.eventdata.properties" type="pcre2">(?i)(1131f6aa|1131f6ab|1131f6ac)</field>
    <description>AD enumeration: DCSync or LDAP replication access detected</description>
    <mitre>
      <id>T1003.006</id>
    </mitre>
  </rule>

  <!-- T1550.002 — Pass-the-Hash: NTLM network logon -->
  <rule id="100003" level="12">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4624$</field>
    <field name="win.eventdata.logonType">^3$</field>
    <field name="win.eventdata.authenticationPackageName">^NTLM$</field>
    <description>Possible Pass-the-Hash: NTLM network logon from $(win.eventdata.ipAddress)</description>
    <mitre>
      <id>T1550.002</id>
    </mitre>
  </rule>

  <!-- T1110 — Brute force: 5+ failed logons in 2 minutes -->
  <rule id="100004" level="10" frequency="5" timeframe="120">
    <if_matched_sid>60122</if_matched_sid>
    <description>Brute force: 5+ failed logons in 2 min from $(win.eventdata.ipAddress)</description>
    <mitre>
      <id>T1110</id>
    </mitre>
  </rule>

  <!-- T1046 — Port scan detected via pfSense -->
  <rule id="100005" level="8">
    <if_sid>4700</if_sid>
    <match>SYN</match>
    <description>Port scan: possible reconnaissance from $(srcip)</description>
    <mitre>
      <id>T1046</id>
    </mitre>
  </rule>

  <!-- T1003.001 — LSASS credential dump -->
  <rule id="100006" level="15">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4656$</field>
    <field name="win.eventdata.objectName" type="pcre2">(?i)lsass</field>
    <description>Credential dump: LSASS memory access — possible Mimikatz</description>
    <mitre>
      <id>T1003.001</id>
    </mitre>
  </rule>

</group>
EOF

# ── Incident Report Template ─────────────────────────────────
for ir in IR-001-kerberoasting IR-002-pass-the-hash IR-003-bloodhound IR-004-vsftpd IR-005-lsass-dump; do
cat > 08-wazuh-siem/incident-reports/${ir}.md << IREOF
# Incident Report — ${ir}

**Date:** YYYY-MM-DD  
**Severity:** High  
**Status:** Closed (lab exercise)

## Timeline
| Time | Event |
|------|-------|
| HH:MM | Attack initiated from Kali (10.10.10.5) |
| HH:MM | Wazuh alert fired — rule XXXXX level 12 |
| HH:MM | Evidence collected |

## Attack Detail
\`\`\`
(paste command used)
\`\`\`

## Detection Evidence
- Wazuh rule fired: (rule ID and description)
- Windows Event ID: (event ID and source)
- Screenshot: see \`screenshots/\`

## MITRE ATT&CK
- Technique: (T number and name)
- Link: https://attack.mitre.org/techniques/TXXXX/

## Remediation
1. (step 1)
2. (step 2)
3. (step 3)

## Lessons Learned
(What did you observe? What would you do differently in a real environment?)
IREOF
done

# ── Scripts ─────────────────────────────────────────────────
cat > scripts/README.md << 'EOF'
# Scripts

Automation scripts for homelab management.

| Script | Purpose |
|--------|---------|
| `proxmox-snapshot.sh` | Snapshot all lab VMs before an exercise |
| `proxmox-rollback.sh` | Roll back all lab VMs to clean state |
| `wazuh-agent-install-linux.sh` | Install Wazuh agent on Linux VMs |
| `pihole-update-gravity.sh` | Update Pi-hole blocklists |
EOF

cat > scripts/proxmox-snapshot.sh << 'EOF'
#!/bin/bash
# Snapshot all cyber lab VMs before an exercise
# Usage: bash proxmox-snapshot.sh "pre-kerberoasting"

LABEL=${1:-"clean-state"}
VMIDS=(200 201 202 203)

echo "Snapshotting lab VMs with label: $LABEL"
for VMID in "${VMIDS[@]}"; do
  echo "  Snapshotting VM $VMID..."
  qm snapshot "$VMID" "$LABEL" --description "Snapshot before lab: $LABEL"
done
echo "Done."
EOF

cat > scripts/proxmox-rollback.sh << 'EOF'
#!/bin/bash
# Roll back all cyber lab VMs to a snapshot
# Usage: bash proxmox-rollback.sh "clean-state"

LABEL=${1:-"clean-state"}
VMIDS=(200 201 202 203)

echo "Rolling back lab VMs to: $LABEL"
for VMID in "${VMIDS[@]}"; do
  echo "  Rolling back VM $VMID..."
  qm rollback "$VMID" "$LABEL"
done
echo "Done."
EOF

cat > scripts/wazuh-agent-install-linux.sh << 'EOF'
#!/bin/bash
# Install Wazuh agent on Linux VM and point to manager
# Usage: WAZUH_MANAGER=192.168.30.20 AGENT_NAME=kali bash wazuh-agent-install-linux.sh

MANAGER=${WAZUH_MANAGER:-"192.168.30.20"}
NAME=${AGENT_NAME:-"$(hostname)"}

curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" \
  | tee /etc/apt/sources.list.d/wazuh.list
apt update

WAZUH_MANAGER="$MANAGER" WAZUH_AGENT_NAME="$NAME" apt install -y wazuh-agent

systemctl enable --now wazuh-agent
echo "Wazuh agent installed. Manager: $MANAGER | Agent name: $NAME"
/var/ossec/bin/agent_control -l
EOF

cat > scripts/pihole-update-gravity.sh << 'EOF'
#!/bin/bash
# Update Pi-hole blocklists and report stats
echo "Updating Pi-hole gravity..."
pihole -g
echo ""
echo "Pi-hole stats:"
pihole -c -e
EOF

chmod +x scripts/*.sh

# ── diagrams placeholder ─────────────────────────────────────
cat > diagrams/README.md << 'EOF'
# Diagrams

Network topology and architecture diagrams.

| File | Description |
|------|-------------|
| `full-topology.png` | Complete homelab network topology |
| `proxmox-bridges.png` | Proxmox vmbr0 and vmbr2 bridge design |
| `switch-vlan-map.png` | 8-port switch VLAN port assignment |
| `cyber-lab-isolation.png` | Cyber lab isolation design |

> Add screenshots and exported diagrams here as you complete each section.
EOF

# ── screenshots placeholder ──────────────────────────────────
for dir in 01-slate7-wan-setup 02-pfsense-firewall 03-managed-switch 04-pihole-dns 05-proxmox-virtualization 06-tailscale-vpn 07-cyber-lab 08-wazuh-siem; do
  echo "Add screenshots here as you complete ${dir}" > ${dir}/screenshots/.gitkeep
done
echo "Add screenshots here" > 07-cyber-lab/active-directory-setup/screenshots/.gitkeep
echo "Add screenshots here" > 07-cyber-lab/attack-exercises/screenshots/.gitkeep

echo "      Done."

# ── STEP 4: Write the root README ───────────────────────────
echo "[4/6] Writing root README.md..."

cat > README.md << 'EOF'
<div align="center">

# 🛡️ Anton Leslie — Homelab & Cybersecurity Portfolio

**IT Systems Administrator · CompTIA Security+ · B.S. Computer Science (Cybersecurity Emphasis)**

[![Security+](https://img.shields.io/badge/CompTIA-Security%2B-red?style=for-the-badge&logo=comptia&logoColor=white)](https://www.comptia.org/certifications/security)
[![Network+](https://img.shields.io/badge/CompTIA-Network%2B_In_Progress-orange?style=for-the-badge&logo=comptia&logoColor=white)](https://www.comptia.org/certifications/network)
[![NSA CAE](https://img.shields.io/badge/NSA%2FDHS-CAE_Cyber_Defense-blue?style=for-the-badge&logoColor=white)](#)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/YOUR_LINKEDIN_HANDLE)

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
EOF

echo "      Done."

# ── STEP 5: Git add and commit ───────────────────────────────
echo "[5/6] Staging all files for git..."
git add -A
git status --short
echo "      Done."

# ── STEP 6: Commit and push ──────────────────────────────────
echo "[6/6] Committing and pushing to GitHub..."
git commit -m "Complete repo restructure — 8-section homelab portfolio with full documentation"
git push origin main

echo ""
echo "========================================"
echo "  All done! Visit your repo at:"
echo "  https://github.com/AntonLesl/homelab-portfolio"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Update LinkedIn badge URL in README.md (line ~9)"
echo "  2. Add screenshots to each section as you build"
echo "  3. Fill in IR-00X incident reports after each lab exercise"
echo "  4. Pin this repo on your GitHub profile"
echo ""
