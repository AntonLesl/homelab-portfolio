# Issues — 04 Pi-hole + DNS Setup

---

## Issue 001 — Pi-hole container could not reach internet after creation

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 20 minutes

### Symptom
After creating the Pi-hole LXC container in Proxmox and trying to run `apt update`, the command hung at:
```
0% [Connecting to archive.ubuntu.com]
```
The container had no internet connectivity at all.

### Root Cause
Two problems combined:
1. pfSense DHCP was handing out `192.168.10.2` (Pi-hole itself) as the DNS server — but Pi-hole didn't exist yet. This created a DNS loop where clients tried to use Pi-hole for DNS before it was running.
2. The Pi-hole container's `/etc/resolv.conf` had no working DNS server configured.

### How I Fixed It
**Fix 1 — Temporary DNS in pfSense:**
```
http://192.168.10.1
Services → DHCP Server → LAN
DNS Server 1: 8.8.8.8
```
Save → Apply Changes.

**Fix 2 — Set DNS inside the container:**
```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

**Verified internet worked:**
```bash
ping 8.8.8.8
ping google.com
```

### Lesson Learned
When building a DNS server, always use a temporary public DNS (8.8.8.8) during setup. Never point DNS to a server that doesn't exist yet — it creates an unresolvable loop. Change back to Pi-hole DNS only after Pi-hole is fully running and tested.

---

## Issue 002 — LXC container failed to start after VLAN tag change

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 30 minutes

### Symptom
After changing the Pi-hole container network from VLAN 10 to VLAN 30, the container failed to start with error:
```
run_buffer: 571 Script exited with status 25
lxc_create_network_priv: 3466 Success - Failed to create network device
lxc_spawn: 1860 Failed to create the network
__lxc_start: 2127 Failed to spawn container "100"
TASK ERROR: startup for container '100' failed
```

### Root Cause
The `vmbr0` bridge was not configured as VLAN-aware. When a container has a VLAN tag assigned, Proxmox requires the bridge to have `bridge-vlan-aware yes` set. Without this, the bridge cannot handle tagged traffic for containers and fails to create the network device.

### How I Fixed It
Edited `/etc/network/interfaces` on Proxmox to add VLAN awareness to vmbr0:
```bash
nano /etc/network/interfaces
```

Added two lines to the vmbr0 block:
```
auto vmbr0
iface vmbr0 inet static
        address 192.168.30.10/24
        gateway 192.168.30.1
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094
```

Applied changes:
```bash
systemctl restart networking
```

Container started successfully after this change.

### Lesson Learned
Any Proxmox bridge that will host containers or VMs with VLAN tags must have `bridge-vlan-aware yes` and `bridge-vids 2-4094` configured. Without these, tagged containers will fail to start.

---

## Issue 003 — Pi-hole container could not ping gateway after VLAN config

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 25 minutes

### Symptom
After configuring Pi-hole container with VLAN tag 30 and IP `192.168.30.2`, the container could not ping the gateway:
```
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
From 192.168.30.2 icmp_seq=1 Destination Host Unreachable
```
pfSense also could not ping Pi-hole:
```
3 packets transmitted, 0 packets received, 100.0% packet loss
```

### Root Cause
Switch port 4 (where Proxmox is connected) is configured as an **untagged** VLAN 30 access port. This means traffic arriving on port 4 is already treated as VLAN 30 — no tagging needed. However, when the container had VLAN tag 30 set AND vmbr0 was VLAN-aware, it was double-tagging the traffic (VLAN 30 tag inside VLAN 30 tag), which the switch could not process.

### How I Fixed It
Removed the VLAN tag from the container network configuration:
1. Shutdown the Pi-hole container
2. Proxmox web GUI → CT 100 → Network → net0 → edit
3. Removed the VLAN tag (left blank)
4. Started container

Since switch port 4 is already untagged VLAN 30, the container does not need an additional VLAN tag — the switch handles the VLAN assignment at the port level.

### Lesson Learned
When a Proxmox host is connected to an **untagged** switch port, containers on that host do not need VLAN tags — the switch already assigns the VLAN. Only add VLAN tags to containers when the host is connected to a **trunk** port that carries multiple VLANs.

---

## Issue 004 — cloudflared DNS proxy no longer supported

**Status:** ✅ Resolved
**Severity:** Medium
**Time to resolve:** 15 minutes

### Symptom
After installing cloudflared and running the proxy-dns command:
```bash
cloudflared proxy-dns --port 5053 --upstream https://1.1.1.1/dns-query
```

Received error:
```
ERR DNS Proxy is no longer supported since version 2026.2.0
dns-proxy feature is no longer supported
```

### Root Cause
Cloudflare removed the `proxy-dns` feature from cloudflared starting in version 2026.2.0. The documentation previously recommended using cloudflared for DNS over HTTPS but this capability was deprecated.

Reference: https://developers.cloudflare.com/changelog/2025-11-11-cloudflared-proxy-dns/

### How I Fixed It
Used **Unbound** as the DNS resolver instead — which is actually Pi-hole's officially recommended approach:

```bash
apt install unbound -y

cat > /etc/unbound/unbound.conf.d/pi-hole.conf << 'EOF'
server:
    verbosity: 0
    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    do-ip6: no
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no
    edns-buffer-size: 1232
    prefetch: yes
    num-threads: 1
    so-rcvbuf: 1m
    private-address: 192.168.0.0/16
    private-address: 10.0.0.0/8
EOF

systemctl enable unbound
systemctl start unbound
```

Updated Pi-hole to use Unbound at port 5335.

### Lesson Learned
Always check current documentation before following older guides. cloudflared proxy-dns was widely recommended until 2026 when it was removed. Unbound is the current recommended solution for Pi-hole recursive DNS and is more performant than DoH anyway.

---

## Issue 005 — nslookup timing out from desktop despite Pi-hole running

**Status:** ✅ Resolved
**Severity:** High
**Time to resolve:** 45 minutes

### Symptom
Pi-hole was running and resolving DNS correctly from within the container:
```bash
dig @127.0.0.1 google.com   # worked
dig @192.168.30.2 google.com # worked from pfSense
```

But from the desktop:
```powershell
nslookup google.com 192.168.30.2   # timed out
```

Packet capture on pfSense showed DNS packets WERE leaving the desktop and reaching pfSense — but no replies came back.

### Root Cause
Pi-hole's `ListeningMode` was set to `LOCAL` in `/etc/pihole/pihole.toml`. In LOCAL mode, Pi-hole only responds to DNS queries that originate from the local machine (127.0.0.1) — it ignores all queries from external IP addresses. Since the desktop was querying from `192.168.10.101`, Pi-hole silently dropped all queries.

### How I Fixed It
Changed Pi-hole listening mode to accept queries from all interfaces:

```bash
nano /etc/pihole/pihole.toml
```

Found the line:
```
ListeningMode = "LOCAL"
```

Changed to:
```
ListeningMode = "all"
```

Restarted Pi-hole DNS:
```bash
pihole restartdns
```

DNS immediately worked from desktop after this change.

### Lesson Learned
Pi-hole v6 defaults to `LOCAL` listening mode which only serves DNS to the local machine. For a network-wide DNS server, `ListeningMode` must be set to `"all"` in `/etc/pihole/pihole.toml`. This is a new default in Pi-hole v6 that differs from older versions.

---

## Issue 006 — pfSense DNS rule not passing traffic to Pi-hole on LAB network

**Status:** ✅ Resolved  
**Severity:** Medium
**Time to resolve:** 20 minutes

### Symptom
Even with a pfSense firewall rule allowing LAN to reach `192.168.30.2:53`, DNS queries from the desktop were being allowed through pfSense (visible in packet capture) but Pi-hole was not receiving them.

### Root Cause
The pfSense outbound NAT was not translating the source IP of DNS packets crossing from LAN (192.168.10.x) to LAB (192.168.30.x). Without NAT, Pi-hole received packets from `192.168.10.101` and tried to reply back — but the reply had no route back to `192.168.10.x` from Pi-hole's perspective since Pi-hole only knew about `192.168.30.x`.

### How I Fixed It
Added outbound NAT rule in pfSense:
```
Firewall → NAT → Outbound → Hybrid mode

Rule:
  Interface: LAN
  Protocol: TCP/UDP
  Source: 192.168.10.0/24
  Destination: 192.168.30.2
  Dest port: 53
  Translation: LAN interface address
```

Combined with fixing the ListeningMode (Issue 005), DNS started working correctly.

### Lesson Learned
When routing DNS across VLANs, NAT reflection or outbound NAT rules are needed to ensure reply traffic can find its way back to the requesting client. Cross-VLAN DNS without NAT requires careful static routing or the replies will be dropped.
