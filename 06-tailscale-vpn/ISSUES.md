# Issues — 06 Tailscale VPN

---

## Issue 001 — `--accept-routes` broke local routing on Proxmox

**Status:** ✅ Resolved
**Severity:** Critical
**Time to resolve:** 30 minutes

### Symptom
After bringing Tailscale up on Proxmox, local network routing broke — services on the LAN became unreachable from the host.

### Root Cause
The subnet router itself was set to `--accept-routes`, so it accepted the very routes it was advertising, creating a routing loop/conflict with its own local networks.

### Investigation
```bash
tailscale status
ip route show
# Observed routes pointing back through the tailnet for local subnets
```

### How I Fixed It
Brought Tailscale back up without `--accept-routes` on the subnet router.

### Lesson Learned
**Never use `--accept-routes` on a subnet router.** The node advertising routes should not also accept routes for the networks it serves.

---

## Issue 002 — IP forwarding kept getting disabled

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 15 minutes

### Symptom
Subnet routing worked, then stopped after reboots — remote devices couldn't reach internal services.

### Root Cause
`net.ipv4.ip_forward` was not persisted, so it reset to 0 on reboot and the subnet router stopped forwarding.

### How I Fixed It
```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```

### Lesson Learned
Runtime sysctl changes don't survive reboots. Persist them in `/etc/sysctl.conf` for anything a subnet router depends on.
