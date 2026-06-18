# Step 4 — Proxmox VE Setup

## What you need
- Server with 16GB+ RAM, 256GB+ SSD, 1 NIC minimum
- Proxmox VE ISO on USB
- Ethernet cable to switch Port 4

---

## 4.1 — Install Proxmox VE

1. Download Proxmox VE ISO from https://www.proxmox.com/downloads

2. Flash to USB:
```bash
# Mac
diskutil list
diskutil unmountDisk /dev/disk2
sudo dd if=proxmox-ve_*.iso of=/dev/rdisk2 bs=1m status=progress
```

3. Boot server from USB → installer launches

4. Network config during install:
```
Management interface:  (your NIC)
Hostname:              proxmox.homelab
IP Address:            192.168.30.10/24
Gateway:               192.168.30.1
DNS Server:            192.168.10.2
```

5. Set root password → complete install → reboot

6. Plug Proxmox NIC into switch Port 4 (VLAN 30)

7. Access web UI from your laptop:
```
https://192.168.30.10:8006
```

Login:
```
Username: root
Password: (set during install)
```

Click through the "no valid subscription" warning — that is fine.

---

## 4.2 — Switch to community repo

Open the Proxmox shell (click node name → Shell):

```bash
# Remove enterprise repo (requires paid subscription)
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/ceph.list 2>/dev/null || true

# Add free community repo
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
  >> /etc/apt/sources.list

# Update and upgrade
apt update && apt dist-upgrade -y

# Install useful tools
apt install -y htop iotop net-tools tcpdump curl wget
```

---

## 4.3 — Configure virtual network bridges

This is the most critical step. Find your NIC name first:

```bash
ip link show
```

Look for something like `enp1s0`, `eno1`, `eth0`. Use whatever shows up — replace `enp1s0` in the config below.

Edit the network config file:

```bash
nano /etc/network/interfaces
```

Delete everything and paste this (replacing `enp1s0` with your NIC name):

```
auto lo
iface lo inet loopback

# Physical NIC — no IP assigned directly
auto enp1s0
iface enp1s0 inet manual

# vmbr0 — Management bridge — VLAN 30
# Proxmox UI, Wazuh, OpenVAS connect here
auto vmbr0
iface vmbr0 inet static
    address 192.168.30.10/24
    gateway 192.168.30.1
    bridge-ports enp1s0
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 30

# vmbr2 — Isolated cyber lab — NO uplink, NO VLAN
# VMs on this bridge cannot reach anything external
# Only exception: static route below for Wazuh log push
auto vmbr2
iface vmbr2 inet manual
    bridge-ports none
    bridge-stp off
    bridge-fd 0

# Static route: lets lab VMs push logs to Wazuh (192.168.30.20) on port 1514 only
post-up   ip route add 10.10.10.0/24 via 192.168.30.20 dev vmbr0
pre-down  ip route del 10.10.10.0/24 via 192.168.30.20 dev vmbr0
```

Save: `Ctrl+X` → `Y` → Enter

Apply:
```bash
systemctl restart networking
```

---

## 4.4 — Verify bridges

```bash
# vmbr0 should show 192.168.30.10
ip addr show vmbr0

# vmbr2 should show NO IP (correct — it is internal only)
ip addr show vmbr2

# Static route should exist
ip route show | grep 10.10.10
# Should show: 10.10.10.0/24 via 192.168.30.20 dev vmbr0

# Proxmox web UI should still be reachable
# Test from laptop: https://192.168.30.10:8006
```

---

## 4.5 — Download Ubuntu template for LXC containers

In Proxmox web UI:

1. Click your local storage (usually called `local`)
2. Click **CT Templates**
3. Click **Templates** button
4. Search for `ubuntu-22.04`
5. Click Download

Or from the shell:

```bash
pveam update
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```

---

## 4.6 — Create Ubuntu VM template (for Wazuh and OpenVAS)

From the Proxmox shell:

```bash
# Download Ubuntu 22.04 cloud image
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
  -O /var/lib/vz/template/iso/ubuntu-22.04-cloud.img

# Create VM template
qm create 9000 \
  --name ubuntu-template \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --serial0 socket \
  --vga serial0 \
  --ostype l26

# Import disk
qm importdisk 9000 /var/lib/vz/template/iso/ubuntu-22.04-cloud.img local-lvm

# Configure boot
qm set 9000 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:vm-9000-disk-0 \
  --ide2 local-lvm:cloudinit \
  --boot c \
  --bootdisk scsi0 \
  --agent enabled=1 \
  --ipconfig0 ip=dhcp

# Convert to template (cannot be started — only cloned)
qm template 9000
```

---

## 4.7 — Verify Proxmox web UI

From your laptop browser:
```
https://192.168.30.10:8006
```

You should see:
- Node listed in left sidebar
- vmbr0 and vmbr2 visible under Network
- Local storage showing the Ubuntu template

---

## 4.8 — Screenshots for GitHub

Take screenshots of:
- Proxmox dashboard showing node
- Network page showing vmbr0 and vmbr2
- Storage showing Ubuntu template

Save to:
```
homelab-portfolio/05-proxmox-virtualization/screenshots/
```

Also save your actual network interfaces file:
```bash
cat /etc/network/interfaces
```
Copy contents into:
```
homelab-portfolio/05-proxmox-virtualization/network-interfaces.conf
```

---

## Done — move to Step 5
