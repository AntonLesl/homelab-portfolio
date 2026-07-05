# Issues — 02 pfSense Firewall

---

## Issue 001 — Wrong installer file format

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 15 minutes

### Symptom
The flashed USB would not boot the pfSense installer.

### Root Cause
Downloaded the wrong image type for the install method — the memstick/USB installer versus the ISO were confused.

### How I Fixed It
Downloaded the correct pfSense CE memstick installer image and re-flashed the USB.

### Lesson Learned
Match the installer image to the media you're using. Read the install docs first: https://docs.netgate.com/pfsense/en/latest/install/download-installer-image.html

---

## Issue 002 — Secure Boot blocked the USB installer

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
The ThinkCentre refused to boot from the pfSense USB.

### Root Cause
UEFI Secure Boot was enabled and blocked the unsigned installer media.

### Investigation
Entered BIOS/UEFI setup at boot and checked the Secure Boot state.

### How I Fixed It
Disabled Secure Boot in UEFI, saved, and booted from USB.

### Lesson Learned
Secure Boot commonly blocks non-Windows install media. Disable it for the install (re-evaluate afterward per your threat model).

---

## Issue 003 — Only one onboard NIC (needed WAN + LAN)

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 30 minutes

### Symptom
pfSense needs at least two interfaces (WAN and LAN), but the M60E has only one onboard NIC.

### Root Cause
Small-form-factor PC with a single ethernet port.

### How I Fixed It
Added a USB ethernet adapter as the second interface and assigned it during the console interface step. (This adapter later caused the flapping issue below — permanent fix is a PCIe NIC.)

### Lesson Learned
Confirm NIC count before choosing firewall hardware. Budget for a PCIe NIC on single-port machines rather than relying on USB.

---

## Issue 004 — WD NVMe incompatible with FreeBSD

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 45 minutes

### Symptom
Install stalled / kernel timeouts when targeting the WD NVMe drive.

### Root Cause
The specific WD NVMe model has known FreeBSD kernel timeout issues.

### How I Fixed It
Swapped to a SATA drive for the pfSense install.

### Lesson Learned
Not all NVMe drives play nicely with FreeBSD. Check hardware compatibility before committing to a boot drive.

---

## Issue 005 — Wrong drive selected during install (USB vs SSD)

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
Nearly installed pfSense onto the wrong device.

### Root Cause
The USB installer media and the internal drive both appear as `da`/disk devices; it wasn't obvious which was the target SSD.

### How I Fixed It
Matched the device by size before selecting the install target, then chose the correct internal drive.

### Lesson Learned
Always confirm the install target by size/model. Installing to the wrong disk wipes the wrong device.

---

## Issue 006 — VLAN subinterface overlapped the LAN subnet

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 20 minutes

### Symptom
Routing conflict after creating a VLAN subinterface.

### Root Cause
Creating a VLAN subinterface using the same subnet as the native LAN caused an overlap the router couldn't resolve.

### How I Fixed It
Kept the trusted LAN on the native LAN interface and created only the lab VLAN as a tagged subinterface on its own subnet.

### Lesson Learned
Plan IP addressing and VLAN assignment before running the setup wizard. The wizard's LAN subnet becomes the foundation and is painful to change afterward.

---

## Issue 007 — USB LAN adapter flapping caused network outages

**Status:** ✅ Partially resolved (permanent fix pending)
**Severity:** Critical
**Time to resolve:** Ongoing

### Symptom
The whole network dropped intermittently — sometimes several times an hour. System logs showed the LAN interface changing link state UP/DOWN repeatedly:
```
<lan_if>: link state changed to DOWN
<lan_if>: link state changed to UP
<lan_if>: 4 link states coalesced
```

### Root Cause
USB ethernet adapters aren't designed for 24/7 use. The adapter loses its USB connection intermittently, dropping the LAN interface and taking everything behind it offline.

### Investigation
```
Status → System Logs → System   (filtered for the LAN interface name)
# Observed dozens of UP/DOWN transitions during outages
```

### How I Fixed It (temporary)
1. Tried different USB ports
2. Swapped to a different USB adapter model
3. Added a nightly reboot cron and an interface-reload cron to clear adapter state

### Permanent Fix Required
Install an Intel I210-T1 PCIe x1 NIC in the M60E's PCIe slot. Intel NICs are rock-solid with FreeBSD and don't flap.

### Lesson Learned
Never use USB ethernet for a production/always-on pfSense LAN. They're fine for initial setup, but budget for a PCIe NIC for anything permanent.
