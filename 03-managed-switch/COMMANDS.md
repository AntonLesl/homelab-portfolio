# Commands — 03 Managed Switch VLAN Configuration

All commands used during Netgear GS308E switch configuration with explanations and references.

---

## Windows — Access Switch Admin Panel

### Set static IP to reach switch
```powershell
netsh interface ip set address "Ethernet" static 192.168.0.100 255.255.255.0 192.168.0.1
```
**What it does:** Sets a static IP on the ethernet adapter matching the switch's default subnet (192.168.0.x) so the admin panel is reachable.
**Reference:** https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-interface-ip

---

### Restore DHCP after switch config
```powershell
netsh interface ip set address "Ethernet" dhcp
ipconfig /release
ipconfig /renew
```
**What it does:** Returns the ethernet adapter to DHCP mode so it gets an IP from pfSense again.

---

### Check current IP
```powershell
ipconfig
```

### Ping switch to verify connectivity
```powershell
ping 192.168.0.239
```
**What it does:** Tests if the Netgear GS308E default management IP is reachable.

---

### Scan for switch IP if default doesn't work
```powershell
for ($i=1; $i -le 254; $i++) { if (Test-Connection -Count 1 -Quiet 192.168.0.$i) { Write-Host "Found: 192.168.0.$i" } }
```
**What it does:** Scans every IP on the 192.168.0.x subnet to find the switch management IP.
**Reference:** https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection

---

### Disable and re-enable ethernet adapter
```
Right click Start → Network Connections
Right click Ethernet → Disable
Wait 10 seconds
Right click Ethernet → Enable
```
**What it does:** Forces Windows to re-initialize the ethernet adapter — fixes issues where ethernet connects briefly then drops.

---

## Netgear GS308E — Admin Panel Steps

All switch configuration done through web interface at `http://192.168.0.239`

```
Default login:
Username: admin
Password: password
```
**Reference:** https://www.netgear.com/support/product/gs308e/

---

### Activate Advanced 802.1Q VLAN mode
```
Switching → VLAN → Advanced 802.1Q VLAN → Activate Mode → Yes
```
**What it does:** Enables Advanced 802.1Q VLAN mode which allows per-port control of tagged vs untagged traffic. Required instead of Basic mode which breaks untagged client connectivity.
**Reference:** https://kb.netgear.com/000064929/

---

### Create VLAN 30
```
Switching → VLAN → Edit VLAN → Add

VLAN ID: 30
Name: LAB
```
**What it does:** Creates VLAN 30 in the switch database. Must be done before assigning any ports to it.
**Reference:** https://kb.netgear.com/000064929/

---

### Configure port membership for VLAN 1 (Default/Trusted)
```
VLAN 1 membership:
Port 1: Tagged      ← trunk to pfSense — pfSense handles 802.1Q tags
Port 2: Untagged    ← trusted device — gets clean ethernet frames
Port 3: Untagged    ← desktop — gets clean ethernet frames
Port 4: Excluded    ← not on VLAN 1
Port 5-8: Untagged  ← spare trusted ports
```
**Reference:** https://kb.netgear.com/000064929/

---

### Configure port membership for VLAN 30 (LAB)
```
VLAN 30 membership:
Port 1: Tagged      ← trunk to pfSense
Port 2: Excluded
Port 3: Excluded
Port 4: Untagged    ← Proxmox — gets clean VLAN 30 frames
Port 5-8: Excluded
```

---

### Configure PVID (Port VLAN ID)
```
Switching → VLAN → Advanced 802.1Q → PVID

Port 1: PVID 1    ← trunk port
Port 2: PVID 1    ← trusted
Port 3: PVID 1    ← desktop trusted
Port 4: PVID 30   ← Proxmox lab
Port 5-8: PVID 1  ← spare
```
**What it does:** PVID tells the switch which VLAN to assign to untagged traffic arriving on each port. Port 4 PVID 30 means Proxmox traffic is assigned to VLAN 30.
**Reference:** https://kb.netgear.com/000064929/

---

### Factory reset switch
```
1. Find pinhole on back of GS308E
2. Insert pin or paperclip
3. Hold 10 seconds until lights flash
4. Release — wait 30 seconds for reboot
5. Access: http://192.168.0.239
6. Login: admin / password
```
**What it does:** Returns switch to factory defaults. Used when config gets into a broken state that is faster to reset than fix.
**Reference:** https://kb.netgear.com/000027092/

---

## Verification Commands

### Verify desktop gets correct IP after switch config
```powershell
ipconfig /release
ipconfig /renew
ipconfig
```
**Expected:** IPv4 Address should be 192.168.10.x when plugged into port 3.

---

### Verify pfSense is reachable
```powershell
ping 192.168.10.1
```
**Expected:** Should reply confirming pfSense LAN gateway is reachable through switch.

---

### Verify internet works through switch
```powershell
ping 8.8.8.8
ping google.com
```

---

## Key References

| Topic | URL |
|-------|-----|
| Netgear GS308E product page | https://www.netgear.com/support/product/gs308e/ |
| GS308E VLAN configuration | https://kb.netgear.com/000064929/ |
| GS308E factory reset | https://kb.netgear.com/000027092/ |
| 802.1Q VLAN explained | https://en.wikipedia.org/wiki/IEEE_802.1Q |
| netsh interface commands | https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-interface-ip |
