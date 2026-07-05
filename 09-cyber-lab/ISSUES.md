# Issues — 09 Cyber Lab

---

## Issue 001 — VirtIO drivers needed for Windows VMs

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 20 minutes

### Symptom
Windows Server / Windows 10 installers couldn't see the virtual disk or network on Proxmox.

### Root Cause
Proxmox presents VirtIO devices by default, and the Windows installer doesn't ship VirtIO drivers.

### How I Fixed It
Attached the VirtIO driver ISO as a second CD-ROM and loaded the storage/network drivers during install (or used SATA/E1000 for install, then switched to VirtIO after installing the guest drivers).

### Lesson Learned
Always have the VirtIO driver ISO ready before installing Windows on Proxmox.

---

## Issue 002 — PowerShell line-continuation errors

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
Multi-line AD setup commands failed with parse errors.

### Root Cause
Incorrect line-continuation — backtick placement / copy-paste line breaks in PowerShell.

### How I Fixed It
Ran the commands as single lines, or used correct backtick continuation with no trailing spaces.

### Lesson Learned
PowerShell line continuation is finicky. When in doubt, put the command on one line.

---

## Issue 003 — No DHCP on the isolated lab bridge

**Status:** ✅ Resolved (by design)
**Severity:** Low
**Time to resolve:** 15 minutes

### Symptom
Lab VMs didn't get IP addresses automatically.

### Root Cause
vmbr2 has no uplink and no DHCP server — that's intentional for isolation.

### How I Fixed It
Assigned static IPs to every lab host on a private lab subnet, with the DC providing DNS for the domain.

### Lesson Learned
An isolated lab needs a deliberate static addressing plan. No DHCP is a feature, not a bug — it keeps the segment self-contained.

---

## Issue 004 — Disabled AD user accounts

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 5 minutes

### Symptom
Newly created domain users couldn't log in.

### Root Cause
Accounts were created disabled (or without meeting the password policy), so authentication failed.

### How I Fixed It
Enabled the accounts and set passwords that meet the domain policy.
```powershell
Enable-ADAccount -Identity "[user]"
```

### Lesson Learned
New AD accounts must be explicitly enabled and satisfy password policy before they can authenticate.
