# Commands — 05 Proxmox VE Setup

All commands used during Proxmox installation and configuration with explanations and references.

---

## Installation

### Flash Proxmox ISO to USB (Mac)
```bash
diskutil list
diskutil unmountDisk /dev/disk2
sudo dd if=proxmox-ve_*.iso of=/dev/rdisk2 bs=1m status=progress
```
**What it does:** Lists disks to find USB, unmounts it, then writes the Proxmox ISO directly to the USB drive using dd.
**Reference:** https://pve.proxmox.com/wiki/Prepare_Installation_Media

---

## Post-Install — Repository Setup

### Remove enterprise repository (requires paid subscription)
```bash
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
```
**What it does:** Comments out the enterprise repo line so apt doesn't throw subscription errors on every update.
**Reference:** https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo

---

### Add free community repository
```bash
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" >> /etc/apt/sources.list
```
**What it does:** Adds the free Proxmox repository that doesn't require a subscription.
**Reference:** https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo

---

### Update and upgrade all packages
```bash
apt update && apt dist-upgrade -y
```
**What it does:** Refreshes package lists and upgrades all packages including kernel updates.
**Reference:** https://pve.proxmox.com/wiki/Upgrade_from_8_to_9

---

### Install useful management tools
```bash
apt install -y htop iotop net-tools tcpdump curl wget
```
**What it does:** Installs monitoring and network tools useful for managing the Proxmox server.
- `htop` = interactive process viewer
- `iotop` = disk I/O monitor
- `net-tools` = includes ifconfig, netstat
- `tcpdump` = packet capture
**Reference:** https://ubuntu.com/server/docs/package-management

---

## Network Configuration

### Find NIC name
```bash
ip link show
```
**What it does:** Lists all network interfaces with their names. Use this to find the correct NIC name (nic0, enp1s0, eth0, etc.) before editing network config.
**Reference:** https://man7.org/linux/man-pages/man8/ip-link.8.html

---

### Edit network interfaces
```bash
nano /etc/network/interfaces
```
**What it does:** Opens the Proxmox network configuration file for editing.
**Reference:** https://pve.proxmox.com/wiki/Network_Configuration

---

### Full network interfaces config used
```
auto lo
iface lo inet loopback

iface nic0 inet manual

# vmbr0 — Management bridge — VLAN 30
auto vmbr0
iface vmbr0 inet static
        address 192.168.30.10/24
        gateway 192.168.30.1
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094

# vmbr2 — Isolated cyber lab — NO uplink, NO physical port
auto vmbr2
iface vmbr2 inet manual
        bridge-ports none
        bridge-stp off
        bridge-fd 0

# Static route for Wazuh log push from lab VMs
post-up   ip route add 10.10.10.0/24 via 192.168.30.20 dev vmbr0
pre-down  ip route del 10.10.10.0/24 via 192.168.30.20 dev vmbr0

iface nic1 inet manual

source /etc/network/interfaces.d/*
```
**What it does:**
- `vmbr0` = management bridge connected to physical NIC, VLAN-aware for tagged container traffic
- `vmbr2` = isolated internal bridge with no physical port — cyber lab VMs have zero external routing
- `post-up route` = one-way path allowing lab VMs to push Wazuh logs only
**Reference:** https://pve.proxmox.com/wiki/Network_Configuration#_linux_bridge

---

### Apply network changes
```bash
systemctl restart networking
```
**What it does:** Restarts the networking service to apply changes in /etc/network/interfaces without rebooting.
**Reference:** https://wiki.debian.org/NetworkConfiguration#Applying_interface_configuration

---

## Network Verification

### Verify vmbr0 has correct IP
```bash
ip addr show vmbr0
```
**Expected output:** Should show `inet 192.168.30.10/24`
**Reference:** https://man7.org/linux/man-pages/man8/ip-address.8.html

---

### Verify vmbr2 has no IP (correct)
```bash
ip addr show vmbr2
```
**Expected output:** Should show NO inet address — only link-local IPv6. This is correct — vmbr2 is an internal-only bridge.
**Reference:** https://pve.proxmox.com/wiki/Network_Configuration#_isolated_bridge

---

### Verify static route exists
```bash
ip route show
```
**What it does:** Shows all routing table entries. Look for `10.10.10.0/24 via 192.168.30.20` confirming the Wazuh log route is active.
**Reference:** https://man7.org/linux/man-pages/man8/ip-route.8.html

---

## LXC Template Management

### Update template list
```bash
pveam update
```
**What it does:** Downloads the latest list of available LXC container templates from Proxmox servers.
**Reference:** https://pve.proxmox.com/pve-docs/pveam.1.html

---

### Download Ubuntu 22.04 template
```bash
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```
**What it does:** Downloads the Ubuntu 22.04 LXC template to local Proxmox storage. Used as base for Pi-hole, Wazuh, and other service containers.
**Reference:** https://pve.proxmox.com/wiki/Linux_Container#pct_container_images

---

### List available templates
```bash
pveam available
```
**What it does:** Shows all available templates that can be downloaded.
**Reference:** https://pve.proxmox.com/pve-docs/pveam.1.html

---

## Proxmox CLI — VM and Container Management

### List all VMs and containers
```bash
qm list    # VMs
pct list   # containers
```
**Reference:** https://pve.proxmox.com/pve-docs/qm.1.html

---

### Start/stop container from CLI
```bash
pct start 100
pct stop 100
```
**What it does:** Starts or stops LXC container with ID 100 from the command line.
**Reference:** https://pve.proxmox.com/pve-docs/pct.1.html

---

### Access container console from CLI
```bash
pct enter 100
```
**What it does:** Opens a shell session inside LXC container 100 directly from Proxmox shell.
**Reference:** https://pve.proxmox.com/pve-docs/pct.1.html

---

### Take VM snapshot
```bash
qm snapshot VMID SNAPSHOTNAME --description "description"
```
**What it does:** Creates a point-in-time snapshot of a VM that can be rolled back to later.
**Reference:** https://pve.proxmox.com/pve-docs/qm.1.html#qm_snapshots

---

### Rollback VM to snapshot
```bash
qm rollback VMID SNAPSHOTNAME
```
**What it does:** Reverts a VM to a previous snapshot state. Used before each cyber lab exercise.
**Reference:** https://pve.proxmox.com/pve-docs/qm.1.html#qm_snapshots

---

## Troubleshooting

### Test connectivity from Proxmox to Pi-hole
```bash
ping 192.168.30.2
```

### Test port is open
```bash
nc -zv 192.168.30.2 53
```
**What it does:** Tests if TCP port 53 is open and reachable on Pi-hole. `-z` = scan only, `-v` = verbose.
**Reference:** https://linux.die.net/man/1/nc

---

### Check routing table
```bash
ip route show
```

### Check all listening ports
```bash
ss -tulnp
```
**What it does:** Shows all TCP and UDP ports currently listening on the system.
**Reference:** https://man7.org/linux/man-pages/man8/ss.8.html
