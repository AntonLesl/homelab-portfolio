# Issues — 06 Tailscale VPN Setup

---

## Issue 001 — Enterprise Proxmox repos blocked Tailscale install

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 10 minutes

### Symptom
Running `curl -fsSL https://tailscale.com/install.sh | sh` on Proxmox produced errors:
```
Err:6 https://enterprise.proxmox.com/debian/ceph-squid trixie InRelease
  401 Unauthorized
Err:7 https://enterprise.proxmox.com/debian/pve trixie InRelease
  401 Unauthorized
E: Failed to fetch enterprise repo — not signed
```
Tailscale installation failed because `apt update` could not complete.

### Root Cause
The Proxmox enterprise repositories require a paid subscription. Without a valid subscription key, the enterprise repos return 401 Unauthorized and block all apt operations including Tailscale installation.

### How I Fixed It
Disabled the enterprise repos before installing Tailscale:
```bash
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/ceph.list 2>/dev/null || true
apt update
```

Then installed Tailscale:
```bash
apt install tailscale -y
```

### Lesson Learned
Always disable Proxmox enterprise repos before running any apt operations on a non-subscribed Proxmox installation. This should be done during initial Proxmox setup (Step 4) to prevent this issue on every subsequent package install.

---

## Issue 002 — IP forwarding disabled — subnet routing not working

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 10 minutes

### Symptom
After running `tailscale up --advertise-routes=192.168.30.0/24`, Tailscale showed a health warning:
```
# Health check:
#     - Subnet routing is enabled, but IP forwarding is disabled.
#       Check that IP forwarding is enabled on your machine.
```
Subnet routes were advertised but devices could not reach `192.168.30.x` through Tailscale.

### Root Cause
Linux requires IP forwarding to be explicitly enabled for a machine to route packets between network interfaces. By default, IP forwarding is disabled on Proxmox. Without it, Tailscale can advertise the subnet route but cannot actually forward packets to devices on that subnet.

### How I Fixed It
Enabled IP forwarding permanently:
```bash
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p
```

Then restarted Tailscale:
```bash
tailscale down
tailscale up --advertise-routes=192.168.30.0/24 --ssh --accept-dns=false
```

Health warning disappeared and subnet routing worked.

### Lesson Learned
IP forwarding must be enabled on any Linux machine acting as a router or VPN exit node. Always enable it when setting up Tailscale subnet routing on Linux. The `sysctl.conf` method makes it persistent across reboots.

---

## Issue 003 — accept-routes flag broke Proxmox local network connectivity

**Status:** ✅ Resolved
**Severity:** Critical
**Time to resolve:** 30 minutes

### Symptom
After running `tailscale up --accept-routes` on Proxmox, all local network connectivity broke:
- pfSense could no longer ping Proxmox (`192.168.30.10`)
- Proxmox web GUI became unreachable at `https://192.168.30.10:8006`
- Only Tailscale IP (`100.111.109.122`) remained reachable

### Root Cause
The `--accept-routes` flag tells Tailscale to accept all subnet routes advertised by other nodes in the tailnet. Since pfSense was advertising `192.168.10.0/24` and Proxmox was advertising `192.168.30.0/24`, enabling accept-routes on Proxmox caused it to route traffic for `192.168.30.0/24` through Tailscale instead of the local interface — effectively routing local traffic through the VPN and breaking direct connectivity.

### How I Fixed It
Had to physically access the Proxmox console to run:
```bash
tailscale down
tailscale up --advertise-routes=192.168.30.0/24 --ssh --accept-dns=false
```

Removed `--accept-routes` from the command. This restored local connectivity immediately.

### Lesson Learned
Never use `--accept-routes` on a Proxmox host that is also advertising subnet routes. It creates a routing loop where local subnet traffic is sent through Tailscale instead of the local interface. Subnet routers should advertise routes but NOT accept routes from other nodes.

---

## Issue 004 — Tailscale down command lost remote access

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 5 minutes

### Symptom
Running `tailscale down` on Proxmox immediately terminated the Tailscale connection — losing all remote access to Proxmox since the only path back was through Tailscale.

### Root Cause
When accessing Proxmox remotely via Tailscale, running `tailscale down` disconnects the only network path being used. This is expected behavior but easy to forget when managing remote machines.

### How I Fixed It
Physically walked to the Proxmox machine and typed the command directly on the console to bring Tailscale back up.

### Lesson Learned
Never run `tailscale down` on a remote machine unless you have an alternative access method (physical console, out-of-band management, second network path). Always have a fallback before disconnecting VPN on a remote system.

---

## Issue 005 — Mac laptop going through Tailscale relay instead of direct

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 5 minutes

### Symptom
Tailscale status showed Mac laptop using relay:
```
100.86.186.126   tieyons-laptop  macOS  active; relay "ord"
```
Relay connections are slower than direct connections.

### Root Cause
Tailscale could not establish a direct peer-to-peer connection between the Mac and Proxmox — likely due to NAT traversal issues or firewall blocking UDP. Tailscale fell back to routing through a relay server in Chicago (ord).

### How I Fixed It
Running `tailscale up --accept-routes` on Mac helped establish a more direct connection path over time. Tailscale automatically upgrades from relay to direct when it can establish a NAT traversal path.

### Lesson Learned
Relay connections work fine for most use cases — they are encrypted end-to-end and just slightly slower. Direct connections establish automatically once Tailscale negotiates NAT traversal. This typically resolves itself within a few minutes.

---

## Issue 006 — High and inconsistent ping times to local devices

**Status:** ✅ Partially resolved
**Severity:** Low
**Time to resolve:** Ongoing

### Symptom
Pinging local devices over LAN showed high and inconsistent times:
```
ping 192.168.30.10
Reply: time=438ms
Reply: time=100ms
Reply: time=591ms
Reply: time=800ms
```
Expected LAN ping should be under 5ms.

### Root Cause
Tailscale was intercepting some local subnet traffic and routing it through the VPN instead of the local switch. The inconsistency came from some packets going directly (1ms) while others went through Tailscale relay (800ms+).

### How I Fixed It
Partially resolved by removing `--accept-routes` from Proxmox Tailscale config. Also added UDP GRO fix:
```bash
ethtool -K vmbr0 rx-udp-gro-forwarding on rx-gro-list off
```

Added permanently to `/etc/network/interfaces`:
```
post-up ethtool -K vmbr0 rx-udp-gro-forwarding on rx-gro-list off
```

### Lesson Learned
When Tailscale subnet routes overlap with local network ranges, some traffic may be routed through Tailscale instead of the local network. This is a known behavior when the same subnet is reachable both locally and through Tailscale. The solution is to ensure only one path exists for each subnet.
