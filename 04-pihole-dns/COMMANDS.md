# Commands — 04 Pi-hole + DNS Setup

All commands used during Pi-hole and DNS setup with explanations and references.

---

## Proxmox — Container Creation

### Download Ubuntu LXC template
```bash
pveam update
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```
**What it does:** Updates the Proxmox appliance template list and downloads the Ubuntu 22.04 template for LXC containers.
**Reference:** https://pve.proxmox.com/wiki/Linux_Container#pct_container_images

---

### Configure vmbr0 as VLAN-aware bridge
```bash
nano /etc/network/interfaces
```

Config added:
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
**What it does:** Makes vmbr0 capable of handling 802.1Q VLAN-tagged traffic for containers and VMs. Required for any container that uses a VLAN tag.
**Reference:** https://pve.proxmox.com/wiki/Network_Configuration#_vlan_802_1q_trunking

---

```bash
systemctl restart networking
```
**What it does:** Applies network interface changes without rebooting.
**Reference:** https://wiki.debian.org/NetworkConfiguration

---

## Pi-hole Container — Initial Setup

### Fix DNS inside container (temporary)
```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```
**What it does:** Overwrites the DNS resolver config with Google's public DNS so the container can reach the internet during setup.
**Reference:** https://man7.org/linux/man-pages/man5/resolv.conf.5.html

---

### Update and upgrade packages
```bash
apt update && apt upgrade -y
```
**What it does:** Refreshes package lists and upgrades all installed packages to latest versions.
**Reference:** https://ubuntu.com/server/docs/package-management

---

### Install curl
```bash
apt install curl -y
```
**What it does:** Installs curl — required to download the Pi-hole installer script.
**Reference:** https://curl.se/docs/

---

## Pi-hole Installation

### Install Pi-hole
```bash
curl -sSL https://install.pi-hole.net | bash
```
**What it does:** Downloads and runs the official Pi-hole installer. `-sSL` = silent, show errors, follow redirects.
**Reference:** https://docs.pi-hole.net/main/basic-install/

---

### Set Pi-hole admin password
```bash
pihole setpassword
```
**What it does:** Sets or changes the Pi-hole web interface admin password interactively.
**Reference:** https://docs.pi-hole.net/core/pihole-command/#password

---

### Check Pi-hole status
```bash
pihole status
```
**What it does:** Shows whether Pi-hole FTL is running and listening on port 53.
**Reference:** https://docs.pi-hole.net/core/pihole-command/#status

---

### Restart Pi-hole DNS
```bash
pihole restartdns
```
**What it does:** Restarts the Pi-hole FTL DNS service and reloads all lists without full restart.
**Reference:** https://docs.pi-hole.net/core/pihole-command/#restartdns

---

### Update gravity (blocklists)
```bash
pihole -g
```
**What it does:** Downloads all configured blocklists and rebuilds the gravity database used for DNS filtering.
**Reference:** https://docs.pi-hole.net/core/pihole-command/#gravity

---

## Unbound — Recursive DNS Resolver

### Install Unbound
```bash
apt install unbound -y
```
**What it does:** Installs Unbound — a validating, recursive DNS resolver used as Pi-hole's upstream instead of a public DNS server.
**Reference:** https://docs.pi-hole.net/guides/dns/unbound/

---

### Create Unbound config for Pi-hole
```bash
cat > /etc/unbound/unbound.conf.d/pi-hole.conf << 'EOF'
server:
    verbosity: 0
    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    do-ip6: no
    prefer-ip6: no
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
```
**What it does:** Creates the Unbound configuration file that makes it listen on localhost port 5335 and perform recursive DNS resolution directly from root servers.
**Reference:** https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound

---

### Enable and start Unbound
```bash
systemctl enable unbound
systemctl start unbound
```
**What it does:** Enables Unbound to start automatically on boot and starts it immediately.
**Reference:** https://www.freedesktop.org/software/systemd/man/systemctl.html

---

### Test Unbound is resolving
```bash
dig @127.0.0.1 -p 5335 google.com
```
**What it does:** Sends a DNS query directly to Unbound on port 5335 to verify it is resolving correctly. `@127.0.0.1` = query this specific server, `-p 5335` = use port 5335.
**Reference:** https://linux.die.net/man/1/dig

---

## Pi-hole Configuration

### Edit Pi-hole config file
```bash
nano /etc/pihole/pihole.toml
```
**What it does:** Opens the Pi-hole v6 configuration file for editing.
**Reference:** https://docs.pi-hole.net/reference/config/

---

### Key settings changed in pihole.toml

**Change upstream DNS to Unbound:**
```toml
upstreams = [
    "127.0.0.1#5335",
    "127.0.0.1#5335"
]
```
**What it does:** Points Pi-hole to use Unbound on port 5335 for all DNS resolution instead of a public DNS server.

**Change listening mode:**
```toml
ListeningMode = "all"
```
**What it does:** Makes Pi-hole respond to DNS queries from ALL network interfaces and IP addresses — not just localhost. Required for network-wide DNS filtering.
**Reference:** https://docs.pi-hole.net/reference/config/#dns

---

## Verification Commands

### Test DNS from Pi-hole itself
```bash
dig @127.0.0.1 google.com
```
**What it does:** Queries Pi-hole directly on the local machine to verify it is resolving DNS.

---

### Test DNS from Pi-hole's external IP
```bash
dig @192.168.30.2 google.com
```
**What it does:** Queries Pi-hole using its network IP to verify it responds to external queries.

---

### Check what ports Pi-hole is listening on
```bash
ss -tulnp | grep 53
```
**What it does:** Shows all UDP/TCP sockets listening on port 53. Confirms Pi-hole FTL and Unbound are both bound to their respective ports.
**Reference:** https://man7.org/linux/man-pages/man8/ss.8.html

---

### Test DNS from Windows desktop
```powershell
nslookup google.com 192.168.30.2
```
**What it does:** Queries Pi-hole at `192.168.30.2` directly from Windows to test DNS resolution from a client device.
**Reference:** https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/nslookup

---

## pfSense — DNS Firewall Rules

### Allow DNS from LAN to Pi-hole
```
Firewall → Rules → LAN → Add

Action:      Pass
Protocol:    TCP/UDP
Source:      LAN net
Destination: 192.168.30.2 (single host)
Dest port:   53
Description: Allow DNS to Pi-hole
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/firewall/rule-methodology.html

---

### Outbound NAT for cross-VLAN DNS
```
Firewall → NAT → Outbound → Hybrid mode

Interface:    LAN
Protocol:     TCP/UDP
Source:       192.168.10.0/24
Destination:  192.168.30.2
Dest port:    53
Translation:  LAN interface address
```
**What it does:** Translates the source IP of DNS packets crossing from LAN to LAB so replies can route back correctly.
**Reference:** https://docs.netgate.com/pfsense/en/latest/nat/outbound.html

---

## Packet Capture — Troubleshooting DNS

### Capture DNS traffic on pfSense
```
Diagnostics → Packet Capture
Interface: LAN
Protocol:  UDP
Port:      53
```
**What it does:** Captures all UDP port 53 traffic on the LAN interface to verify DNS queries are leaving the desktop and reaching pfSense.
**Reference:** https://docs.netgate.com/pfsense/en/latest/diagnostics/packet-capture.html

---

### Capture DNS on Pi-hole container
```bash
tcpdump -i eth0 port 53
```
**What it does:** Captures all traffic on port 53 on the Pi-hole eth0 interface to verify queries are actually arriving at Pi-hole.
**Reference:** https://www.tcpdump.org/manpages/tcpdump.1.html
