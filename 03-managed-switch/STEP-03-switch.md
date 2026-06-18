# Step 3 — Managed Switch VLAN Configuration

## What you need
- 8-port managed switch (TP-Link TL-SG108E or similar)
- 4 ethernet cables minimum
- Laptop to access switch admin panel

---

## 3.1 — Physical connections

```
pfSense LAN NIC ──► Switch Port 1   (trunk)
Pi-hole         ──► Switch Port 2   (VLAN 10)
Laptop          ──► Switch Port 3   (VLAN 10)
Proxmox NIC     ──► Switch Port 4   (VLAN 30)
Ports 5–8       ──► Spare
```

For initial config connect your laptop directly to any switch port first (before VLAN config is applied).

---

## 3.2 — Access switch admin panel

Default switch IP varies by brand. Check the label on the bottom.

**TP-Link TL-SG108E:**
```
Default IP:  192.168.0.1
Username:    admin
Password:    admin
```

Open browser → go to the default IP.

If you can't reach it, do a factory reset (hold reset button 10 seconds), then try again.

---

## 3.3 — Set switch management IP

System → IP Setting:
```
IP Address:    192.168.30.200
Subnet Mask:   255.255.255.0
Gateway:       192.168.30.1
DHCP:          Disable
```

Save. Reconnect your laptop to port 4 temporarily and go to:
```
http://192.168.30.200
```

Login again with admin credentials.

---

## 3.4 — Enable 802.1Q VLAN

VLAN → 802.1Q VLAN

Enable 802.1Q VLAN if toggle is shown. Click Apply.

---

## 3.5 — Create VLAN 10

VLAN → 802.1Q VLAN → Add:

```
VLAN ID:    10
VLAN Name:  TRUSTED

Port 1:   Tagged      ← trunk to pfSense — carries tag
Port 2:   Untagged    ← Pi-hole access port
Port 3:   Untagged    ← laptop access port
Port 4:   Not Member
Port 5:   Not Member
Port 6:   Not Member
Port 7:   Not Member
Port 8:   Not Member
```

Click Apply.

---

## 3.6 — Create VLAN 30

VLAN → 802.1Q VLAN → Add:

```
VLAN ID:    30
VLAN Name:  LAB

Port 1:   Tagged      ← trunk to pfSense
Port 2:   Not Member
Port 3:   Not Member
Port 4:   Untagged    ← Proxmox access port
Port 5:   Not Member
Port 6:   Not Member
Port 7:   Not Member
Port 8:   Not Member
```

Click Apply.

---

## 3.7 — Set PVID for access ports

VLAN → 802.1Q PVID Setting:

```
Port 1:   PVID 1     (trunk — leave default)
Port 2:   PVID 10    ← Pi-hole gets VLAN 10
Port 3:   PVID 10    ← laptop gets VLAN 10
Port 4:   PVID 30    ← Proxmox gets VLAN 30
Port 5:   PVID 1     (unused)
Port 6:   PVID 1     (unused)
Port 7:   PVID 1     (unused)
Port 8:   PVID 1     (unused)
```

Click Apply.

---

## 3.8 — Connect pfSense to switch

Plug ethernet cable from pfSense LAN NIC into switch Port 1.

pfSense sends tagged VLAN 10 and VLAN 30 traffic down this trunk.

---

## 3.9 — Verify

Plug your laptop into switch Port 3.

```bash
# Mac
ipconfig getifaddr en0
```

Should return `192.168.10.x` — confirms VLAN 10 is working.

```bash
ping 192.168.10.1      # pfSense TRUSTED gateway
ping 8.8.8.8           # internet (DNS may fail until Pi-hole is up — that is OK)
```

**If you get 169.254.x.x** (APIPA address):
- PVID is wrong for that port — recheck Step 3.7
- Or pfSense DHCP is not running on VLAN 10 — recheck Step 2.6

---

## 3.10 — Screenshots for GitHub

Take screenshots of:
- VLAN 10 membership table
- VLAN 30 membership table
- PVID settings page

Save to:
```
homelab-portfolio/03-managed-switch/screenshots/
```

---

## Done — move to Step 4
