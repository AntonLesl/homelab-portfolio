# Issues — 10 Suricata IDS

---

## Issue 001 — Suricata in IPS mode on the WAN froze the whole network

**Status:** ✅ Resolved
**Severity:** Critical
**Time to resolve:** 45 minutes

### Symptom
Enabling Suricata in inline IPS mode on the WAN interface froze all network traffic — nothing in or out.

### Root Cause
Inline IPS puts Suricata directly in the packet path. On top of the unstable USB WAN NIC and limited hardware, the inline processing overwhelmed the interface and stalled traffic.

### How I Fixed It
Switched Suricata to **IDS (alert-only) mode** and moved inspection to the **LAN** interface. This gives detection without the inline throughput/stability cost.

### Lesson Learned
IPS mode is expensive and unforgiving on weak/unstable NICs. On limited hardware, start with IDS (alert) mode; only go inline once the hardware (a proper PCIe NIC) can handle it.

---

## Issue 002 — Hardware offloading corrupted inspection

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
Suricata behaved inconsistently — missed or misfired on traffic it should have caught.

### Root Cause
NIC hardware checksum/segmentation offloading altered packets before Suricata inspected them.

### How I Fixed It
Disabled hardware checksum offload in pfSense (System → Advanced → Networking) and rebooted.

### Lesson Learned
Always disable hardware offloading when running IDS/IPS — the engine must inspect the real packets, not offloaded/modified ones.

---

## Issue 003 — Rules updating blocked package installs (apt)

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
A blocking rule interfered with legitimate package/update traffic during setup.

### Root Cause
An overly broad enabled rule category flagged/blocked normal update traffic.

### How I Fixed It
Tuned the enabled rule categories, disabling the ones that flagged legitimate management traffic.

### Lesson Learned
Enable rule categories deliberately. Turning everything on generates noise and can disrupt legitimate traffic.

---

## Issue 004 — No categories enabled (no alerts at all)

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
Suricata ran but never produced alerts.

### Root Cause
No rule categories were enabled after installing the package, so there were no signatures to match against.

### How I Fixed It
Enabled the relevant Emerging Threats categories, updated rules, and confirmed alerts in `fast.log`.

### Lesson Learned
Installing the IDS isn't enough — you must enable rule categories and update signatures before it detects anything.
