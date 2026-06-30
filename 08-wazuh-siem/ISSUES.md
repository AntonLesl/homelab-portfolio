# Issues — 07 Wazuh SIEM Setup

---

## Issue 001 — Wazuh container had no internet on first boot

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 5 minutes

### Symptom
After creating the Wazuh LXC container and trying to run `apt update`, received DNS resolution failures and could not reach the internet.

### Root Cause
The container DNS was set to `192.168.30.2` (Pi-hole) during creation but Pi-hole was not fully configured yet. This caused DNS failures blocking all package downloads.

### How I Fixed It
```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

Then ran apt update successfully.

### Lesson Learned
Always use `8.8.8.8` as DNS when creating new containers during the build process. Switch to Pi-hole DNS after Pi-hole is fully tested and working.

---

## Issue 002 — Proxmox rebooted unexpectedly during Wazuh install

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 45 minutes

### Symptom
During the Wazuh installation process Proxmox became unreachable. The Wazuh install was interrupted.

### Root Cause
The ThinkCentre running Proxmox had a BIOS reset due to a dead/dying CMOS battery. When power was cycled the BIOS loaded defaults and the machine required F1 to continue booting.

### How I Fixed It
Pressed F1 on the ThinkCentre to continue booting with loaded defaults. Proxmox came back up. Restarted the Wazuh install from scratch on a new container.

### Lesson Learned
Replace the CMOS battery on the ThinkCentre. A dead CMOS battery causes BIOS settings to reset on every power cycle which is a reliability risk for a 24/7 server.

---

## Issue 003 — USB ethernet adapter on pfSense causing network instability

**Status:** ✅ Partially resolved
**Severity:** Critical
**Time to resolve:** Ongoing

### Symptom
pfSense would go offline every few hours. All network devices would lose connectivity including Proxmox, Pi-hole, and desktop. pfSense system logs showed:
```
ue0: link state changed to DOWN
ue0: link state changed to UP
ue0: 4 link states coalesced
```
The USB ethernet adapter (ue0) was flapping up and down dozens of times.

### Root Cause
USB ethernet adapters are not designed for 24/7 server use. The adapter was overheating or losing connection intermittently causing the entire LAN interface to drop. Since ue0 is the LAN NIC for pfSense, when it drops all VLAN 30 traffic (Proxmox, Pi-hole, Wazuh) loses its gateway.

### How I Fixed It
Swapped the USB ethernet adapter for a different model. Added a cron job in pfSense to reboot at 3 AM daily as a temporary workaround:
```
Minute: 0  Hour: 3  Command: /sbin/shutdown -r now
```

### Permanent Fix Required
Install an Intel PCIe NIC in the ThinkCentre M60E PCIe x1 slot:
```
Recommended: Intel I210-T1 PCIe x1 single port gigabit ~$25
```
This eliminates the USB adapter entirely and provides rock-solid LAN connectivity.

### Lesson Learned
Never use USB ethernet adapters for pfSense LAN interfaces in production or always-on environments. Always use PCIe NICs. USB adapters work for initial setup but fail under sustained load.

---

## Issue 004 — Proxmox lost gateway after reboot

**Status:** ✅ Resolved (temporary fix)
**Severity:** High
**Time to resolve:** 20 minutes

### Symptom
After Proxmox rebooted, containers (Pi-hole, Wazuh) could not reach the gateway at `192.168.30.1`. pfSense could ping Proxmox but Proxmox could not ping pfSense. ARP table showed `192.168.30.1` as FAILED.

### Root Cause
The USB ethernet adapter swap changed the MAC address of the pfSense LAN interface. The ARP cache on Proxmox still had the old MAC address. After reboot ARP requests were going to the wrong MAC and getting no replies.

### How I Fixed It
Got the new MAC address from pfSense:
```bash
# On pfSense shell
ifconfig ue0.30
# New MAC: 00:0e:c6:47:3b:22
```

Added permanent ARP entry on Proxmox:
```bash
ip neigh replace 192.168.30.1 lladdr 00:0e:c6:47:3b:22 dev vmbr0 nud permanent
```

### Lesson Learned
When swapping network adapters on pfSense, the MAC address changes. All devices that have ARP cache entries for the old MAC need to be updated. A permanent ARP entry on Proxmox prevents this from being an issue on future reboots — until the PCIe NIC is installed.

---

## Issue 005 — Wazuh dashboard certificate warning

**Status:** ✅ Accepted (known behavior)
**Severity:** Low
**Time to resolve:** 2 minutes

### Symptom
Browser shows certificate warning when accessing `https://192.168.30.20`. Cannot access dashboard without accepting the warning.

### Root Cause
Wazuh uses a self-signed certificate by default. Browsers do not trust self-signed certificates.

### How I Fixed It
Clicked "Accept risk and continue" in browser. For internal homelab use this is acceptable.

### Proper Fix (future)
Set up a proper SSL certificate using Let's Encrypt via Nginx Proxy Manager or add the Wazuh CA certificate to browser trust store.

### Lesson Learned
For production environments always use properly signed certificates. For homelab, self-signed is acceptable as long as you understand the security implications.
