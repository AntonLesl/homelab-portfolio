# Issues — 03 Managed Switch VLAN Configuration

---

## Issue 001 — Could not access switch admin panel

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
Browser could not reach the Netgear GS308E admin panel. Tried `http://192.168.0.239` and `http://192.168.0.1` — both timed out.

### Root Cause
Desktop was on the `192.168.10.x` subnet (assigned by pfSense DHCP). The Netgear GS308E default management IP is `192.168.0.239` on a completely different subnet. A device on `192.168.10.x` cannot reach `192.168.0.x` without routing — which pfSense was not configured to provide to the switch management subnet.

### How I Fixed It
Set a static IP on the desktop matching the switch subnet:
```powershell
netsh interface ip set address "Ethernet" static 192.168.0.100 255.255.255.0 192.168.0.1
```
Then accessed `http://192.168.0.239` — loaded immediately.

After switch configuration was complete, restored DHCP:
```powershell
netsh interface ip set address "Ethernet" dhcp
ipconfig /renew
```

### Lesson Learned
Before accessing any switch or network device management interface, set a static IP on your client matching the device's management subnet. Always restore DHCP after configuration is done.

### Verification
```
Static IP set: 192.168.0.100
http://192.168.0.239 → Netgear login page loaded
Login: admin / password ✅
```

---

## Issue 002 — Basic 802.1Q trunk mode broke ALL ethernet connectivity ⭐

**Status:** ✅ Resolved
**Severity:** Critical
**Time to resolve:** 2+ hours including multiple factory resets

### Symptom
After setting port 1 to Trunk in Basic 802.1Q VLAN mode on the GS308E:
- Every device on the switch immediately lost ethernet connection
- Ethernet adapter showed "trying to connect" briefly then dropped
- Could not reach switch admin panel
- Could not reach pfSense web GUI
- Running `ipconfig /renew` hung indefinitely
- Multiple cable swaps and port changes made no difference
- Required factory reset to recover

### Root Cause
This is a critical limitation of the Netgear GS308E Basic 802.1Q implementation.

When a port is set to **Trunk** in Basic mode, the GS308E tags ALL outbound traffic on that port including VLAN 1 (the default/native VLAN). This means:

```
Port 1 set to Trunk (Basic mode):
  → Switch sends 802.1Q tagged frames on VLAN 1 out port 1
  → pfSense receives tagged frames ← pfSense handles this fine

Port 3 (access port, VLAN 1):
  → Switch sends 802.1Q tagged frames to desktop ← PROBLEM
  → Standard PC NIC cannot process tagged ethernet frames
  → NIC drops all frames silently
  → Desktop loses connection completely
```

The switch appeared to be functioning but NO client could get or maintain a connection because all frames were tagged at the switch level before reaching the NIC.

### How I Fixed It
Factory reset the switch to clear the broken config:
```
1. Found reset button on back of GS308E (small pinhole)
2. Inserted paperclip — held 10 seconds until lights flashed
3. Released — waited 30 seconds for reboot
4. Set static IP: 192.168.0.100
5. Accessed: http://192.168.0.239
```

Then selected **Advanced 802.1Q VLAN** mode instead of Basic:
```
Switching → VLAN → Advanced 802.1Q VLAN → Activate Mode → Yes
```

In Advanced mode configured properly:
```
VLAN 1 port membership:
  Port 1: Tagged      ← pfSense handles 802.1Q tags
  Port 2: Untagged    ← desktop gets clean ethernet frames
  Port 3: Untagged    ← desktop gets clean ethernet frames
  Port 5-8: Untagged  ← spare

VLAN 30 port membership:
  Port 1: Tagged      ← pfSense handles 802.1Q tags
  Port 4: Untagged    ← Proxmox gets clean ethernet frames

PVID:
  Port 1: 1   Port 2: 1   Port 3: 1
  Port 4: 30  Port 5-8: 1
```

Result: pfSense received tagged frames on port 1 and processed them correctly. Desktop on port 3 received clean untagged VLAN 1 frames and connected immediately.

### Why Advanced Works and Basic Doesn't
```
Basic 802.1Q Trunk:
  ALL ports receive tagged frames including access ports
  PC NIC drops tagged frames → no connection ❌

Advanced 802.1Q:
  Port 1 (trunk): Tagged — pfSense processes 802.1Q ✅
  Port 3 (access): Untagged — NIC processes normal ethernet ✅
  Correct separation between tagged trunk and untagged access ✅
```

### Lesson Learned
**On the Netgear GS308E: ALWAYS use Advanced 802.1Q VLAN mode. Never use Basic 802.1Q for trunk configurations.**

Basic trunk mode on this switch sends tagged frames to access ports which is incorrect behavior. Advanced mode properly separates tagged trunk traffic from untagged access port traffic. This is a GS308E-specific behavior and is the most important lesson from the entire switch configuration.

### Verification
```
After Advanced 802.1Q config:
  Port 1 light: green ✅ (pfSense connected)
  Port 3 light: green ✅ (desktop connected)

ipconfig /renew completed in under 5 seconds
IPv4 Address: 192.168.10.101 ✅
Gateway: 192.168.10.1 ✅
ping 8.8.8.8 → replies ✅
http://192.168.10.1 → pfSense GUI loaded ✅
```

---

## Issue 003 — Management VLAN ID error when saving port config

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 5 minutes

### Symptom
When trying to save port configuration in the switch admin panel, received error:
```
Failed to set Management VLAN ID with empty VLAN.
```
Could not save any port settings.

### Root Cause
Attempted to assign port 4 to VLAN 30 before VLAN 30 had been created in the switch. The switch cannot assign a port to a VLAN that does not yet exist — throwing the error above.

### How I Fixed It
Created VLAN 30 first under Edit VLAN before touching port configuration:
```
Switching → VLAN → Edit VLAN → Add
VLAN ID: 30
Name: LAB
Save
```

Then went back to port configuration and assigned port 4 to VLAN 30 — saved without error.

### Lesson Learned
Always create VLANs first, then assign ports. The switch requires the VLAN to exist before any port can be assigned to it.

### Verification
```
VLAN 30 (LAB) created ✅
Port 4 assigned to VLAN 30 ✅
Saved without error ✅
```

---

## Issue 004 — Multiple factory resets required during troubleshooting

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes total across 3 resets

### Symptom
Had to factory reset the switch 3 times during the VLAN configuration process. Each failed attempt left the switch in an inconsistent state where some ports were partially configured and others were not. Attempting to fix on top of broken config made things progressively worse.

### Root Cause
Each incorrect VLAN or port configuration attempt corrupted the running config. The Basic 802.1Q trunk issue (Issue 002 above) was the primary trigger — after losing all ethernet, the switch config was in an unknown state and attempting repairs without a clean baseline was not productive.

### How I Fixed It
Factory reset the switch to return to a known clean state each time:
```
Factory reset procedure:
1. Find pinhole on back of GS308E
2. Insert paperclip or pin
3. Hold for 10 seconds until all port lights flash
4. Release and wait 30 seconds for full reboot
5. Set static IP: 192.168.0.100
6. Access: http://192.168.0.239
7. Login: admin / password
8. Start config from scratch
```

The third reset was the successful one — after understanding that Advanced 802.1Q was required, the full config was completed in under 10 minutes.

### Lesson Learned
Factory reset is not a failure — it is a valid and fast troubleshooting step. Returning to a known clean state is faster than trying to diagnose a partially broken config. Once you know the correct steps, the full switch config takes under 10 minutes. Do not be afraid to reset and start over.

### Verification
```
After third factory reset and correct Advanced 802.1Q config:
  Full switch configuration completed in under 10 minutes
  All devices connecting correctly ✅
```

---

## Issue 005 — Ethernet icon flashing then dropping on desktop

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** Resolved as part of Issue 002

### Symptom
Desktop ethernet adapter showed "trying to connect" with a flashing icon for a few seconds then dropped completely. Repeated every time a cable was plugged in. No IP was assigned. Running `ipconfig /renew` hung and never completed.

### Root Cause
Same root cause as Issue 002 — Basic 802.1Q trunk mode was causing the switch to send tagged ethernet frames to the desktop access port. The desktop NIC detected a link (causing the brief flash) but could not process the tagged frames and dropped the connection immediately.

### How I Fixed It
Resolved completely when switching to Advanced 802.1Q mode as documented in Issue 002. Once access ports were set to Untagged in Advanced mode, the desktop connected and held a stable connection immediately.

### Lesson Learned
A flashing ethernet icon that repeatedly connects and drops is a sign that the NIC is detecting link but cannot process the frames it is receiving. On a managed switch this almost always means the port is sending tagged frames the NIC cannot handle — check VLAN mode configuration.

### Verification
```
After Advanced 802.1Q config with Untagged access ports:
  Ethernet icon showed steady connected state ✅
  IP assigned: 192.168.10.101 ✅
  Connection held stable with no drops ✅
```
