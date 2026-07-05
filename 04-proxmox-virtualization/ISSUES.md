# Issues — 04 Proxmox VE

---

## Issue 001 — BIOS resets on every power cycle

**Status:** ✅ Resolved (workaround) — hardware fix pending
**Severity:** High
**Time to resolve:** 20 minutes

### Symptom
On any power loss the machine dropped to BIOS and required a keypress to continue booting — bad for a 24/7 server.

### Root Cause
The CMOS/BIOS battery is dead, so BIOS settings reset to defaults on every power cycle.

### How I Fixed It
Short term: press F1 to continue boot; re-set boot order. Permanent fix: replace the CMOS battery.

### Lesson Learned
A dead CMOS battery is a real reliability risk for an always-on box. Replace it — a $2 part prevents boot failures after outages.

---

## Issue 002 — NVMe drive issues during install

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 30 minutes

### Symptom
Install problems on the original NVMe drive.

### Root Cause
Drive compatibility/capacity issues with the original small NVMe.

### How I Fixed It
Installed a new 500GB SSD for Proxmox and reinstalled.

### Lesson Learned
Give the hypervisor a healthy, roomy SSD from the start — VM/container images and ISOs eat space fast.

---

## Issue 003 — Proxmox lost its gateway after a reboot

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 20 minutes

### Symptom
After a reboot, containers couldn't reach the gateway. pfSense could ping Proxmox, but Proxmox couldn't ping pfSense. The ARP entry for the gateway showed FAILED.

### Root Cause
The pfSense USB adapter had been swapped, changing its MAC. Proxmox still had the old MAC cached in ARP, so requests went to a MAC that no longer existed.

### Investigation
```bash
ip neigh show
# gateway entry showed FAILED
```

### How I Fixed It
Read the new MAC from pfSense, then pinned a permanent ARP entry on Proxmox:
```bash
ip neigh replace [gateway ip] lladdr [new firewall LAN MAC] dev vmbr0 nud permanent
```

### Lesson Learned
Swapping a NIC changes its MAC, which invalidates cached ARP entries on peers. A permanent ARP entry is a good stopgap; the real fix is the PCIe NIC (so the MAC stops changing).
