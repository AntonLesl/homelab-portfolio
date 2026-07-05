# Issues — 07 Wazuh SIEM

---

## Issue 001 — Install failed / had to restart on a fresh container

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 30 minutes

### Symptom
The Wazuh install was interrupted (a power/BIOS reset event on the host mid-install) and left in a partial state.

### Root Cause
The host dropped to BIOS on a power cycle (dead CMOS battery — see Proxmox ISSUES.md), interrupting the install.

### How I Fixed It
Brought the host back up (F1 to continue boot), spun up a clean container, and reran the Wazuh installer from scratch.

### Lesson Learned
Don't run long installs on a box with a known dead CMOS battery until it's fixed. A clean re-install on a fresh container is more reliable than trying to repair a half-finished one.

---

## Issue 002 — Network outages during setup (USB NIC flapping upstream)

**Status:** ✅ Resolved (upstream fix)
**Severity:** High
**Time to resolve:** Tied to pfSense fix

### Symptom
Wazuh lost connectivity to agents/firewall intermittently during setup.

### Root Cause
Upstream pfSense USB LAN adapter flapping (see pfSense Issue 007) dropped the whole segment including the SIEM.

### How I Fixed It
Applied the pfSense workarounds (adapter swap, reboot/reload cron) and pinned the Proxmox ARP entry. Permanent fix is the PCIe NIC.

### Lesson Learned
A SIEM is only as reliable as the network under it. Infrastructure stability issues cascade into monitoring gaps — fix the foundation first.
