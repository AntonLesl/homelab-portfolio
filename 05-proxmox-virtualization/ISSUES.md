# Issues — 05 Proxmox VE Setup

---

## Issue 001 — Could not reach Proxmox web GUI from desktop on VLAN 10

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 20 minutes

### Symptom
After installing Proxmox and plugging it into switch port 4 (VLAN 30), could not access the web GUI at `https://192.168.30.10:8006` from the desktop on VLAN 10. Browser showed "This site can't be reached".

### Root Cause
The pfSense firewall rule was blocking all traffic from LAN (192.168.10.x) to LAB (192.168.30.x). This is correct security behavior — but we need to be able to reach Proxmox management from the trusted network.

### How I Fixed It
Added a specific allow rule in pfSense for Proxmox web GUI access:
```
Firewall → Rules → LAN → Add

Action:       Pass
Protocol:     TCP
Source:       LAN net
Destination:  192.168.30.10
Dest port:    8006
Description:  Allow Proxmox web GUI from trusted
```

Save → Apply Changes.

### Lesson Learned
When segmenting networks with a default-deny firewall, always add explicit allow rules for management interfaces you need to access. Block all, allow specific is the correct approach — just remember to allow what you actually need.

---

## Issue 002 — Proxmox plugged into wrong switch port

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 5 minutes

### Symptom
After Proxmox was installed and powered on, pinging `192.168.30.10` timed out. Proxmox was unreachable on the expected IP.

### Root Cause
Proxmox NIC was plugged into switch port 2 (VLAN 1 — trusted network) instead of switch port 4 (VLAN 30 — lab network). This meant Proxmox was getting a `192.168.10.x` DHCP address instead of the configured static `192.168.30.10`.

### How I Fixed It
Moved the ethernet cable from switch port 2 to switch port 4.

After moving:
```powershell
ping 192.168.30.10   # replied immediately
```

### Lesson Learned
Always double-check physical cable connections match the intended switch port VLAN assignment. Label cables and ports during setup to avoid confusion.

---

## Issue 003 — Proxmox could not reach internet on VLAN 30

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
After getting Proxmox on the correct port, the desktop (temporarily moved to port 4 to test) had no internet access on VLAN 30. DNS queries and web traffic failed.

### Root Cause
pfSense LAB interface firewall rules were missing allow rules for internet access and DNS. The default-deny policy blocked all outbound traffic from VLAN 30.

### How I Fixed It
Added rules to pfSense LAB interface:
```
Firewall → Rules → LAB → Add

Rule 1:
  Action:      Pass
  Protocol:    TCP/UDP
  Source:      LAB net
  Destination: any
  Port:        80, 443
  Description: Allow LAB internet access

Rule 2:
  Action:      Pass
  Protocol:    TCP/UDP
  Source:      LAB net
  Destination: any
  Port:        53
  Description: Allow LAB DNS
```

Also fixed DHCP DNS for LAB to use `8.8.8.8` temporarily instead of `192.168.10.2` (Pi-hole not built yet).

### Lesson Learned
Each VLAN interface in pfSense needs its own firewall rules. Adding a new VLAN does not automatically give it internet access — all rules must be explicitly created.

---

## Issue 004 — vmbr0 bridge not VLAN-aware causing container failures

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 25 minutes

### Symptom
After creating the Pi-hole LXC container with a VLAN tag assigned, the container failed to start with error:
```
Failed to create network device
TASK ERROR: startup for container '100' failed
```

### Root Cause
The default Proxmox vmbr0 bridge is not VLAN-aware out of the box. When a container has a VLAN tag, Proxmox needs the bridge to support 802.1Q tagging internally. Without `bridge-vlan-aware yes`, the bridge cannot create the virtual network interface for tagged containers.

### How I Fixed It
Added VLAN awareness to vmbr0 in `/etc/network/interfaces`:
```bash
nano /etc/network/interfaces
```

Added to vmbr0 block:
```
bridge-vlan-aware yes
bridge-vids 2-4094
```

Full vmbr0 config:
```
auto vmbr0
iface vmbr0 inet static
        address 192.168.30.10/24
        gateway 192.168.30.1
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094
```

Applied:
```bash
systemctl restart networking
```

### Lesson Learned
Always configure `bridge-vlan-aware yes` on Proxmox bridges if any containers or VMs will use VLAN tags. This should be part of the initial Proxmox network setup before creating any VMs.

---

## Issue 005 — Desktop getting VLAN 10 IP even after moving to switch port 4

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
After physically moving desktop cable from switch port 3 to switch port 4, `ipconfig` still showed `192.168.10.101` instead of a `192.168.30.x` IP.

### Root Cause
Windows cached the old DHCP lease and did not automatically request a new one after the port change. The old lease was still valid so Windows kept using it.

### How I Fixed It
```powershell
ipconfig /release
ipconfig /renew
ipconfig
```

After renew, desktop showed `192.168.30.100` confirming VLAN 30 was working correctly.

### Lesson Learned
Always run `ipconfig /release` and `ipconfig /renew` after changing switch ports or VLAN assignments. Windows will hold onto old DHCP leases until forced to renew.

---

## Issue 006 — Cannot change network settings on running LXC container

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 2 minutes

### Symptom
When trying to change the Pi-hole container's network settings (VLAN tag, IP) through Proxmox web GUI while it was running, received error:
```
Parameter verification failed. (400)
net0: unable to hotplug net0: no physical interface on bridge 'vmbr0'
```

### Root Cause
Proxmox does not allow hot-plugging network interface changes on LXC containers while they are running. Network configuration changes require the container to be stopped first.

### How I Fixed It
Shutdown the container first:
- Proxmox web GUI → CT 100 → Shutdown → wait for stop
- Then made network changes
- Then started container again

### Lesson Learned
Always stop LXC containers before changing network configuration. Plan network settings carefully during creation to avoid needing to stop and reconfigure later.
