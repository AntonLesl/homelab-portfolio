# Issues — 05 Pi-hole + Unbound DNS

---

## Issue 001 — cloudflared removed in Pi-hole 2026.2.0

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
The planned cloudflared DNS-over-HTTPS upstream was no longer available after a Pi-hole update.

### Root Cause
cloudflared support was deprecated/removed in Pi-hole 2026.2.0.

### How I Fixed It
Switched to Unbound as a local recursive resolver — Pi-hole's own officially recommended approach.
```bash
apt install unbound -y
```

### Lesson Learned
Don't hard-depend on a single upstream method. Unbound recursive resolution is more self-contained and privacy-preserving anyway.

---

## Issue 002 — Pi-hole container had no internet (double-tagging)

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 25 minutes

### Symptom
The Pi-hole LXC couldn't reach the internet.

### Root Cause
A VLAN tag was set on the container's network device, but the switch access port it rode on was already untagged for that VLAN — producing double-tagging, which the switch dropped.

### How I Fixed It
Removed the VLAN tag from the container's NIC. The access port already places it on the correct VLAN; the container must not add its own tag.

### Lesson Learned
Tag in exactly one place. If the switch access port is untagged for a VLAN, the endpoint must not also tag — double-tagging silently breaks connectivity.

---

## Issue 003 — Cross-VLAN DNS from trusted LAN timed out

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 45 minutes

### Symptom
DNS queries from trusted-LAN clients to Pi-hole (on the lab VLAN) timed out even after adding a firewall allow rule.

### Root Cause
Two things combined: Pi-hole's `ListeningMode` was `LOCAL` (rejecting foreign-subnet queries), and there was no outbound NAT so Pi-hole's replies couldn't route back across VLANs.

### Investigation
```
# pfSense packet capture confirmed queries reached pfSense but not Pi-hole
Diagnostics → Packet Capture → LAN → UDP → port 53

# On Pi-hole
grep -i "ListeningMode" /etc/pihole/pihole.toml
# ListeningMode = "LOCAL"
```

### How I Fixed It
1. Set `ListeningMode = "all"` in `/etc/pihole/pihole.toml` and restarted Pi-hole
2. Added an outbound NAT rule on pfSense translating trusted-LAN DNS to the firewall's LAN address (see pfSense COMMANDS.md)

### Lesson Learned
Cross-VLAN service access needs both the firewall (allow + NAT) and the service (listen on the right interfaces) configured. A single allow rule isn't enough.
