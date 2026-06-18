# Step 2 — pfSense Firewall Setup

## What you need
- Mini PC or Protectli with 2 NICs (WAN + LAN)
- pfSense CE ISO on USB
- Laptop connected to pfSense LAN port for initial setup

---

## 2.1 — Install pfSense

1. Download pfSense CE from https://www.pfsense.org/download/
   - Architecture: AMD64
   - Installer: DVD Image (ISO)

2. Flash to USB:
```bash
# Mac
diskutil list                          # find your USB disk (e.g. /dev/disk2)
diskutil unmountDisk /dev/disk2
sudo dd if=pfSense-CE-*.iso of=/dev/rdisk2 bs=1m status=progress
```

3. Boot mini PC from USB → follow installer → accept all defaults

4. When asked to assign interfaces:
```
WAN → the NIC connected to Slate 7 LAN port
LAN → the NIC connected to your switch (or laptop for now)
```

5. After install and reboot, the console shows:
```
WAN → v4/DHCP: 192.168.8.2   (from Slate 7 DMZ)
LAN → v4: 192.168.1.1
```

---

## 2.2 — Access web GUI

Connect laptop directly to pfSense LAN NIC with ethernet cable.

Open browser:
```
http://192.168.1.1
```

Login:
```
Username: admin
Password: pfsense
```

**Change password immediately** — System → User Manager → admin → change password.

---

## 2.3 — Run setup wizard

System → Setup Wizard:

```
Hostname:          pfsense
Domain:            homelab.local
Primary DNS:       (leave blank — Pi-hole handles this later)
Secondary DNS:     (leave blank)

WAN type:          DHCP (gets IP from Slate 7)

LAN IP:            192.168.10.1
LAN Subnet:        255.255.255.0  (/24)

Admin password:    (set strong password)
```

Click Finish. pfSense will reload. Reconnect to:
```
http://192.168.10.1
```

---

## 2.4 — Create VLANs

Interfaces → Assignments → VLANs → Add

**VLAN 10 — TRUSTED:**
```
Parent interface:  igb1  (your LAN NIC — check Interfaces → Assignments to confirm name)
VLAN Tag:          10
Description:       TRUSTED
```
Save.

**VLAN 30 — LAB:**
```
Parent interface:  igb1
VLAN Tag:          30
Description:       LAB
```
Save.

---

## 2.5 — Assign VLAN interfaces

Interfaces → Assignments

In the "Available network ports" dropdown you will see:
```
VLAN 10 on igb1
VLAN 30 on igb1
```

Click Add for each. Two new interfaces appear: OPT1, OPT2.

**Configure OPT1 (VLAN 10 TRUSTED):**

Click OPT1:
```
Enable:                   ✓ checked
Description:              TRUSTED
IPv4 Configuration Type:  Static IPv4
IPv4 Address:             192.168.10.1 / 24
```
Save → Apply Changes.

**Configure OPT2 (VLAN 30 LAB):**

Click OPT2:
```
Enable:                   ✓ checked
Description:              LAB
IPv4 Configuration Type:  Static IPv4
IPv4 Address:             192.168.30.1 / 24
```
Save → Apply Changes.

---

## 2.6 — Configure DHCP on each VLAN

Services → DHCP Server

**TRUSTED tab:**
```
Enable:           ✓ checked
Range from:       192.168.10.100
Range to:         192.168.10.200
DNS Server 1:     192.168.10.2      ← Pi-hole (not live yet — OK)
DNS Server 2:     (leave blank)     ← forces all DNS through Pi-hole
Gateway:          192.168.10.1
```
Save.

**LAB tab:**
```
Enable:           ✓ checked
Range from:       192.168.30.100
Range to:         192.168.30.200
DNS Server 1:     192.168.10.2      ← Pi-hole
DNS Server 2:     (leave blank)
Gateway:          192.168.30.1
```
Save.

---

## 2.7 — Add static DHCP leases

Services → DHCP Server → TRUSTED → Static Mappings → Add:
```
MAC Address:    (Pi-hole MAC — add after Pi-hole is created in Step 5)
IP Address:     192.168.10.2
Hostname:       pihole
Description:    Pi-hole DNS
```

Services → DHCP Server → LAB → Static Mappings → Add:
```
MAC Address:    (Proxmox MAC — add after Proxmox is installed in Step 4)
IP Address:     192.168.30.10
Hostname:       proxmox
```

Add more after building each service:
```
Wazuh:    192.168.30.20
OpenVAS:  192.168.30.30
Switch:   192.168.30.200
```

---

## 2.8 — Firewall rules

Firewall → Rules

**TRUSTED interface rules** (click TRUSTED tab → Add):

Rule 1 — Allow internet:
```
Action:       Pass
Interface:    TRUSTED
Protocol:     TCP/UDP
Source:       TRUSTED net
Destination:  any
Dest port:    80, 443
Description:  Allow internet access
```

Rule 2 — Allow DNS to Pi-hole only:
```
Action:       Pass
Protocol:     TCP/UDP
Source:       TRUSTED net
Destination:  192.168.10.2
Dest port:    53
Description:  DNS to Pi-hole only
```

Rule 3 — Block trusted to lab:
```
Action:       Block
Source:       TRUSTED net
Destination:  LAB net
Description:  Block TRUSTED to LAB
```

Rule 4 — Default deny (pfSense adds this automatically at the bottom)

**LAB interface rules** (click LAB tab → Add):

Rule 1 — Allow internet for updates:
```
Action:       Pass
Protocol:     TCP/UDP
Source:       LAB net
Destination:  any
Dest port:    80, 443
Description:  Internet for VM updates
```

Rule 2 — Allow DNS to Pi-hole:
```
Action:       Pass
Protocol:     TCP/UDP
Source:       LAB net
Destination:  192.168.10.2
Dest port:    53
Description:  DNS to Pi-hole
```

Rule 3 — Block lab to trusted:
```
Action:       Block
Source:       LAB net
Destination:  TRUSTED net
Description:  Block LAB to TRUSTED
```

Click Apply Changes after all rules are added.

---

## 2.9 — Enable syslog to Wazuh (add after Step 7)

Status → System Logs → Settings:
```
Enable Remote Logging:   ✓ checked
Remote log server:       192.168.30.20
Remote Syslog Port:      514
Protocol:                UDP
Syslog Contents:         ✓ Firewall Events
                         ✓ DHCP Events
                         ✓ System Events
```
Save.

---

## 2.10 — Verify

Connect laptop to switch port 3 (VLAN 10 — after Step 3).

```bash
# On your laptop
ping 192.168.10.1       # pfSense gateway — should reply
ping 8.8.8.8            # internet — should reply
ipconfig getifaddr en0  # should show 192.168.10.x
```

Cross-VLAN block test (should FAIL):
```bash
ping 192.168.30.10      # Proxmox — should be blocked
```

---

## 2.11 — Screenshots for GitHub

Take screenshots of:
- Interfaces → Assignments showing TRUSTED and LAB
- DHCP Server settings for both VLANs
- Firewall rules for TRUSTED and LAB
- WAN status showing public IP

Save to:
```
homelab-portfolio/02-pfsense-firewall/screenshots/
```

---

## Done — move to Step 3
