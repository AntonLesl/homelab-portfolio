# Issues — 11 OpenVAS / Greenbone

---

## Issue 001 — Proxmox community helper script returned an empty file

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 10 minutes

### Symptom
The Proxmox community script for OpenVAS downloaded a 0-byte file and did nothing.

### Root Cause
OpenVAS had been removed from the Proxmox community-scripts repository; the URL returned a 404.

### How I Fixed It
Used the official Greenbone Community Edition Docker setup instead:
```bash
curl -fsSL https://greenbone.github.io/docs/latest/_static/setup-and-start-greenbone-community-edition.sh -o gce-setup.sh
bash gce-setup.sh
```

### Lesson Learned
Community helper scripts come and go. Fall back to the vendor's official install method when one disappears.

---

## Issue 002 — Docker not available in the container

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 5 minutes

### Symptom
`bash gce-setup.sh` reported that Docker wasn't available.

### Root Cause
Docker wasn't installed in the container yet.

### How I Fixed It
```bash
curl -fsSL https://get.docker.com | sh
```

### Lesson Learned
Read a setup script's prerequisites first — the Greenbone script assumes Docker is already present.

---

## Issue 003 — Disk filled up repeatedly during feed sync

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 30 minutes (across several fills)

### Symptom
The setup failed multiple times with no-space-left errors while pulling images and syncing the feed.

### Root Cause
The Greenbone Docker images plus the vulnerability feed are large — far bigger than the container's initial disk.

### Investigation
```bash
df -h   # root filesystem at 100% each time it failed
```

### How I Fixed It
Expanded the LXC disk to comfortably fit the images and feed, then reran the setup.

### Lesson Learned
Size the vuln-scanner's disk generously up front. The feed and images are big and grow over time.

---

## Issue 004 — Docker overlay filesystem failed in an unprivileged LXC

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 30 minutes

### Symptom
Docker couldn't create its overlay storage inside the container.

### Root Cause
An unprivileged LXC can't run Docker's overlay filesystem without the right features/permissions.

### How I Fixed It
Converted the container to **privileged** and enabled the required features in the LXC config:
```
features: nesting=1,keyctl=1,fuse=1
lxc.apparmor.profile: unconfined
```

### Lesson Learned
Docker-inside-LXC needs a privileged container with nesting/keyctl/fuse and an unconfined AppArmor profile. (Understand the security tradeoff before doing this in production.)

---

## Issue 005 — nginx bound only to localhost (web UI unreachable)

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
The Greenbone web UI (GSA) wasn't reachable from other hosts.

### Root Cause
The reverse proxy was bound to localhost, so only the container itself could reach it.

### How I Fixed It
Adjusted the port binding so the UI listened on the container's LAN-reachable address, then confirmed access from the management network.

### Lesson Learned
Check what address a service binds to. "Works locally" often means it's bound to localhost and needs to be exposed on the right interface.
