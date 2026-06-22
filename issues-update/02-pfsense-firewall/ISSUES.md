# Issues — 02 pfSense Firewall Setup

---

## Issue 001 — Wrong pfSense file format — USB would not boot

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 20 minutes

### Symptom
After flashing USB with Rufus using the downloaded pfSense file, the USB either would not boot or the installer failed to load correctly.

### Root Cause
Downloaded the `.iso` file from the pfSense downloads page. For bare metal USB installs, pfSense requires the `amd64 memstick USB` image which comes as a `.img.gz` file — not an ISO. ISOs are only for virtual machine installs via IPMI or virtual CD drives.

### How I Fixed It
1. Went back to `https://www.pfsense.org/download/`
2. Selected: `amd64` → `memstick USB` → downloaded `.img.gz`
3. Extracted `.img.gz` with 7-Zip: right click → 7-Zip → Extract Here → produced `.img` file
4. Opened balenaEtcher (not Rufus)
5. Flash from file → selected `.img` → selected USB → Flash
6. USB booted pfSense installer correctly

### Lesson Learned
pfSense for bare metal installation = memstick USB image (`.img.gz`). ISO = virtual machines only. Always use balenaEtcher for `.img` files — it handles them without any settings to configure.

### Verification
```
balenaEtcher showed "Flash Complete" with green checkmark
ThinkCentre booted pfSense installer from USB successfully
```

---

## Issue 002 — ThinkCentre would not boot from USB

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
After flashing the correct `.img` file, ThinkCentre kept booting into Windows instead of the USB installer no matter how many times the USB was plugged in.

### Root Cause
Secure Boot and Fast Boot were both enabled in the ThinkCentre BIOS. Secure Boot blocks any non-Microsoft-signed boot media including pfSense. Fast Boot skips the hardware detection phase making it impossible to interrupt and select a different boot device.

### How I Fixed It
1. Powered on ThinkCentre → spammed `F1` key to enter BIOS
2. Navigated to: Security → Secure Boot → set to **Disabled**
3. Navigated to: Startup → Fast Boot → set to **Disabled**
4. Navigated to: Startup → Boot Mode → set to **Legacy**
5. Pressed `F10` to save and exit
6. On reboot spammed `F12` → boot menu appeared → selected USB drive
7. pfSense installer loaded

### Lesson Learned
Always disable Secure Boot before attempting USB boot on any modern PC. Fast Boot must also be disabled or the boot menu will not appear even when pressing the correct key. These two settings block USB booting more than any other issue.

### Verification
```
F12 boot menu appeared on reboot
USB drive listed as a boot option
pfSense installer loaded successfully
```

---

## Issue 003 — Only one NIC detected — cannot assign WAN and LAN

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 30 minutes

### Symptom
After pfSense booted, the interface assignment screen only showed one network interface (`re0`). pfSense requires a minimum of two NICs — one for WAN and one for LAN. Could not proceed with setup.

### Root Cause
The Lenovo ThinkCentre mini PC only has one built-in ethernet port. This is common with mini PCs and SFF (small form factor) machines. pfSense needs at minimum two separate network interfaces to function as a router/firewall.

### How I Fixed It
Added a USB ethernet adapter:
1. Plugged USB ethernet adapter into a USB port on the ThinkCentre
2. Rebooted pfSense
3. pfSense detected the USB adapter automatically as `ue0`
4. Interface list now showed two NICs: `re0` (built-in) and `ue0` (USB adapter)
5. Assigned: WAN = `re0`, LAN = `ue0`

### Lesson Learned
Always verify NIC count before purchasing hardware for pfSense. Mini PCs and NUCs commonly only have one NIC. USB ethernet adapters work reliably as a second NIC and pfSense supports them natively. Cost around $15–20 and solve the problem immediately.

### Verification
```
pfSense interface list showed:
  re0   00:xx:xx:xx:xx:xx  (built-in NIC)
  ue0   00:xx:xx:xx:xx:xx  (USB adapter)

WAN assigned to re0 ✅
LAN assigned to ue0 ✅
```

---

## Issue 004 — WD NVMe SSD timeout errors during install

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 45 minutes

### Symptom
During pfSense installation, repeated error messages appeared:
```
resetting controller due to a timeout (nda:0:nvme0:0:1): periph destroyed
```
The installer would freeze or crash. Multiple attempts all produced the same timeout error.

### Root Cause
The WD NVMe SSD (model: WDC WDS256G1X0C-00ENX0) installed in the ThinkCentre has documented compatibility issues with FreeBSD — which is the operating system pfSense is built on. The FreeBSD NVMe driver does not communicate reliably with certain WD NVMe controllers, causing repeated timeouts that prevent installation.

Various sysctl fixes were attempted:
```bash
sysctl kern.geom.debugflags=16
nvmecontrol power -p 0 nda0
echo 'hw.nvme.retry_count=10' >> /boot/loader.conf
```
None resolved the issue permanently.

### How I Fixed It
Installed pfSense on a separate Seagate SATA hard drive instead of the NVMe SSD:
1. Connected the Seagate SATA drive to the ThinkCentre
2. Rebooted pfSense installer
3. Selected the Seagate drive as install target
4. Installation completed without any errors

### Lesson Learned
WD NVMe drives are not compatible with pfSense/FreeBSD. Always use a SATA SSD for pfSense installations. Samsung, Crucial, and Seagate SATA drives all work reliably. This is a known and documented issue in the pfSense community.

### Verification
```
Seagate SATA drive selected as install target
Installation completed successfully with no timeout errors
pfSense booted from Seagate drive without issues
```

---

## Issue 005 — Failed to select installation disk — da0 is the USB boot drive

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 20 minutes

### Symptom
When selecting the installation disk in the pfSense installer, selecting `da0` produced the error "failed to select installation disk" and "device busy". Attempts to partition da0 also failed with "not permitted".

### Root Cause
`da0` was the USB flash drive that pfSense was booting from — not the internal hard drive. The installer cannot install onto the drive it is actively using to boot. The internal Seagate drive was actually `da1`. This was not obvious from the installer screen alone.

### How I Fixed It
Used the Shell option in the pfSense installer to identify drives:
```bash
# From installer → select Shell
camcontrol devlist
# Output showed:
# da0  SanDisk USB (USB boot drive)
# da1  Seagate HDD (internal drive) ← this is the target

geom disk list
# Confirmed sizes: da0 = USB size, da1 = full HDD size

gpart destroy -F da1    # wiped old partition table
gpart create -s gpt da1 # created fresh GPT partition table
exit                     # returned to installer
```
Then selected `da1` in the installer — installation proceeded successfully.

### Lesson Learned
Always use Shell during pfSense installation to identify which device number corresponds to the USB drive vs the internal drive. `da0` is almost always the USB boot drive. Never guess — verify with `camcontrol devlist` before selecting a disk.

### Verification
```bash
camcontrol devlist
# Confirmed: da0 = USB, da1 = internal Seagate

# Selected da1 in installer
# Installation completed successfully
```

---

## Issue 006 — VLAN 10 IP conflicts with existing LAN interface

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 10 minutes

### Symptom
When attempting to create VLAN 10 for the trusted network with IP `192.168.10.1/24`, pfSense showed the error:
```
IPv4 address 192.168.10.1/24 is being used by or overlaps with: LAN (192.168.10.1/24)
```
VLAN 10 could not be created.

### Root Cause
During the pfSense setup wizard, the LAN interface was configured with IP `192.168.10.1/24` — which was the intended IP for the trusted network. pfSense cannot assign the same IP to both the physical LAN interface and a VLAN subinterface — they would overlap and conflict.

### How I Fixed It
Recognized that the LAN interface was already serving as the trusted network at `192.168.10.1`. Instead of creating a separate VLAN 10, used LAN directly as the trusted network and only created VLAN 30 for the lab.

Final design:
```
LAN    (ue0)      → 192.168.10.1/24  ← trusted network (used directly)
VLAN30 (ue0.30)   → 192.168.30.1/24  ← lab network (created as VLAN)
```

This is actually a cleaner design — one less VLAN to manage and pfSense handles it natively.

### Lesson Learned
If the LAN interface IP already matches your intended trusted subnet, use LAN directly as the trusted network. There is no need to create a separate VLAN for it. Only create VLANs for additional segments beyond what LAN already provides.

### Verification
```
pfSense console shows:
  WAN  (re0)    → 192.168.8.130/24
  LAN  (ue0)    → 192.168.10.1/24   ← trusted
  LAB  (ue0.30) → 192.168.30.1/24   ← lab

All three interfaces UP ✅
```
