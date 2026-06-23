# Commands — 02 pfSense Firewall Setup

All commands used during pfSense installation and configuration with explanations and references.

---

## USB Flash Drive Preparation (Mac)

### Find USB disk number
```bash
diskutil list
```
**What it does:** Lists all disks and partitions. Find your USB drive by size.
**Reference:** https://ss64.com/mac/diskutil.html

---

### Unmount USB drive
```bash
diskutil unmountDisk /dev/disk2
```
**What it does:** Unmounts all partitions on the disk so it can be written to. Replace `disk2` with your disk number.

---

### Flash pfSense image to USB (balenaEtcher recommended)
```
Open balenaEtcher
Flash from file → select pfSense .img file
Select target → select USB drive
Flash
```
**Reference:** https://etcher.balena.io/

---

### Extract .img.gz file (7-Zip on Windows)
```
Right click .img.gz file → 7-Zip → Extract Here
```
**What it does:** Extracts the compressed .img.gz to produce the .img file needed for flashing.
**Reference:** https://www.7-zip.org/

---

## pfSense Installation — Shell Commands

### List all detected drives
```bash
camcontrol devlist
```
**What it does:** Shows all storage devices detected by the system including their device names (da0, da1, ada0). Used to identify which device is the USB vs internal drive.
**Reference:** https://www.freebsd.org/cgi/man.cgi?camcontrol

---

### Show drive sizes
```bash
geom disk list
```
**What it does:** Shows detailed info about all disks including size. Used to confirm which device number is the USB and which is the internal drive.
**Reference:** https://www.freebsd.org/cgi/man.cgi?geom

---

### Wipe partition table from drive
```bash
gpart destroy -F da1
```
**What it does:** Destroys all partition tables on the specified drive (`da1`). Required before pfSense can write its own partition layout. Replace `da1` with your target drive.
**Reference:** https://www.freebsd.org/cgi/man.cgi?gpart

---

### Create new GPT partition table
```bash
gpart create -s gpt da1
```
**What it does:** Creates a fresh GPT (GUID Partition Table) on the drive ready for pfSense installation.
**Reference:** https://www.freebsd.org/cgi/man.cgi?gpart

---

### Exit Shell back to installer
```bash
exit
```

---

## pfSense Console — Interface Assignment

### pfSense console menu options
```
1) Assign Interfaces
2) Set interface(s) IP address
8) Shell
16) Restart PHP-FPM
```

### Interface assignment used
```
WAN: re0   (built-in NIC connected to Slate 7)
LAN: ue0   (USB ethernet adapter connected to switch)
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/install/assign-interfaces.html

---

## pfSense Web GUI — Configuration

### Access pfSense web GUI
```
http://192.168.10.1
Default login: admin / pfsense
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/config/

---

### Create VLAN 30 (LAB)
```
Interfaces → Assignments → VLANs → Add

Parent interface: ue0
VLAN Tag: 30
Description: LAB
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/vlan/index.html

---

### Assign VLAN 30 as interface
```
Interfaces → Assignments → Add (VLAN 30 on ue0)
Click OPT1 → configure:

Enable: ✓
Description: LAB
IPv4: Static
IP: 192.168.30.1/24
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/interfaces/assign.html

---

### Configure DHCP on LAN
```
Services → DHCP Server → LAN

Enable: ✓
Range: 192.168.10.100 - 192.168.10.200
DNS Server 1: 192.168.30.2  (Pi-hole)
DNS Server 2: (blank)
Gateway: 192.168.10.1
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/services/dhcp/server.html

---

### Configure DHCP on LAB
```
Services → DHCP Server → LAB

Enable: ✓
Range: 192.168.30.100 - 192.168.30.200
DNS Server 1: 192.168.30.2  (Pi-hole)
DNS Server 2: (blank)
Gateway: 192.168.30.1
```

---

### LAN Firewall Rules
```
Firewall → Rules → LAN

Rule 1 — Allow internet:
  Action: Pass | Protocol: Any | Source: LAN net | Dest: any

Rule 2 — Allow DNS to Pi-hole:
  Action: Pass | Protocol: TCP/UDP | Source: LAN net | Dest: 192.168.30.2 | Port: 53

Rule 3 — Allow Proxmox GUI:
  Action: Pass | Protocol: TCP | Source: LAN net | Dest: 192.168.30.10 | Port: 8006

Rule 4 — Block LAN to LAB:
  Action: Block | Source: LAN net | Dest: 192.168.30.0/24
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/firewall/rule-methodology.html

---

### LAB Firewall Rules
```
Firewall → Rules → LAB

Rule 1 — Allow internet:
  Action: Pass | Protocol: TCP/UDP | Source: LAB net | Dest: any | Port: 80, 443

Rule 2 — Allow DNS:
  Action: Pass | Protocol: TCP/UDP | Source: LAB net | Dest: any | Port: 53

Rule 3 — Allow Wazuh logs:
  Action: Pass | Protocol: TCP | Source: LAB net | Dest: 192.168.30.20 | Port: 1514

Rule 4 — Block LAB to LAN:
  Action: Block | Source: LAB net | Dest: LAN net
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/firewall/

---

### Outbound NAT for cross-VLAN DNS
```
Firewall → NAT → Outbound → Hybrid Outbound NAT → Add

Interface: LAN
Protocol: TCP/UDP
Source: 192.168.10.0/24
Destination: 192.168.30.2
Dest port: 53
Translation: LAN interface address
Description: NAT DNS to Pi-hole
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/nat/outbound.html

---

### Enable syslog to Wazuh (do after Step 7)
```
Status → System Logs → Settings

Enable Remote Logging: ✓
Remote log server: 192.168.30.20
Port: 514
Protocol: UDP
Log: Firewall Events, DHCP, System, Authentication
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/monitoring/logs/remote.html

---

## Windows — Testing Commands

### Release and renew DHCP lease
```powershell
ipconfig /release
ipconfig /renew
```
**Reference:** https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig

---

### Test DNS resolution
```powershell
nslookup google.com
nslookup google.com 192.168.30.2
```
**Reference:** https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/nslookup

---

### Test connectivity
```powershell
ping 192.168.10.1   # pfSense LAN gateway
ping 192.168.30.10  # Proxmox
ping 8.8.8.8        # internet
ping google.com     # DNS + internet
```

---

## Key References

| Topic | URL |
|-------|-----|
| pfSense documentation | https://docs.netgate.com/pfsense/en/latest/ |
| VLAN configuration | https://docs.netgate.com/pfsense/en/latest/vlan/index.html |
| Firewall rules | https://docs.netgate.com/pfsense/en/latest/firewall/rule-methodology.html |
| DHCP server | https://docs.netgate.com/pfsense/en/latest/services/dhcp/server.html |
| NAT outbound | https://docs.netgate.com/pfsense/en/latest/nat/outbound.html |
| pfSense install guide | https://docs.netgate.com/pfsense/en/latest/install/ |
| FreeBSD gpart | https://www.freebsd.org/cgi/man.cgi?gpart |
| FreeBSD camcontrol | https://www.freebsd.org/cgi/man.cgi?camcontrol |
