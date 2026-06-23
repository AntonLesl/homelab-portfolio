# Commands — 06 Tailscale VPN Setup

All commands used during Tailscale installation and configuration with explanations and references.

---

## Proxmox — Pre-Installation Fix

### Disable enterprise repos before installing
```bash
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/ceph.list 2>/dev/null || true
apt update
```
**What it does:** Comments out Proxmox enterprise repository lines that require a paid subscription. Without this, apt operations fail with 401 Unauthorized errors blocking any package installation.
**Reference:** https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo

---

## Proxmox — Tailscale Installation

### Install Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```
**What it does:** Downloads and runs the official Tailscale install script. Automatically detects the OS (Debian/Ubuntu/etc) and adds the correct apt repository, then installs the tailscale package.
**Reference:** https://tailscale.com/download/linux

---

### Alternative — install from apt after repo is added
```bash
apt install tailscale -y
```
**What it does:** Installs Tailscale from the apt repository that was added by the install script.
**Reference:** https://pkgs.tailscale.com/stable/debian/

---

### Enable IP forwarding (required for subnet routing)
```bash
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p
```
**What it does:**
- Adds IP forwarding settings to `/etc/sysctl.conf` (persists across reboots)
- `sysctl -p` applies the settings immediately without rebooting
- Required for Tailscale to forward packets between its VPN interface and local network interfaces
**Reference:** https://tailscale.com/kb/1019/subnets/#enable-ip-forwarding

---

### Start Tailscale and advertise subnet
```bash
tailscale up --advertise-routes=192.168.30.0/24 --ssh --accept-dns=false
```
**What it does:**
- `--advertise-routes=192.168.30.0/24` — tells Tailscale to advertise the Proxmox LAB subnet so other Tailscale devices can reach it
- `--ssh` — enables Tailscale SSH so you can SSH to Proxmox using its Tailscale hostname without keys
- `--accept-dns=false` — prevents Tailscale from overriding Proxmox's DNS settings (Pi-hole handles DNS)

This prints a URL to authenticate Proxmox in the Tailscale admin panel.
**Reference:** https://tailscale.com/kb/1019/subnets/

---

### Enable Tailscale auto-start on boot
```bash
systemctl enable tailscaled
```
**What it does:** Configures Tailscale daemon to start automatically when Proxmox boots. Without this, Tailscale stops after every reboot.
**Reference:** https://www.freedesktop.org/software/systemd/man/systemctl.html

---

### Check Tailscale status
```bash
tailscale status
```
**What it does:** Shows all devices in your Tailscale network, their IPs, connection type (direct/relay), and any health warnings.
**Reference:** https://tailscale.com/kb/1080/cli/#status

---

### Bring Tailscale down
```bash
tailscale down
```
**What it does:** Disconnects from Tailscale network. WARNING — if accessing remotely via Tailscale this will cut your connection. Only run from physical console.
**Reference:** https://tailscale.com/kb/1080/cli/#down

---

### Fix UDP GRO forwarding for better performance
```bash
ethtool -K vmbr0 rx-udp-gro-forwarding on rx-gro-list off
```
**What it does:** Optimizes UDP packet processing on the vmbr0 bridge for Tailscale. Fixes the warning:
```
Warning: UDP GRO forwarding is suboptimally configured on vmbr0
```
Improves Tailscale throughput and reduces latency.
**Reference:** https://tailscale.com/s/ethtool-config-udp-gro

---

### Make UDP GRO fix permanent
Add to `/etc/network/interfaces` inside vmbr0 block:
```
post-up ethtool -K vmbr0 rx-udp-gro-forwarding on rx-gro-list off
```
**What it does:** Runs the ethtool command automatically every time vmbr0 comes up — survives reboots.
**Reference:** https://pve.proxmox.com/wiki/Network_Configuration

---

## pfSense — Tailscale Package

### Install Tailscale on pfSense
```
System → Package Manager → Available Packages
Search: tailscale → Install → Confirm
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/packages/list.html

---

### Configure pfSense Tailscale
```
VPN → Tailscale → Settings

Enable Tailscale:     ✓ checked
Login Server:         https://login.tailscale.com
Pre-auth Key:         tskey-auth-xxxxxxxxxxxx  (generated from Tailscale admin)
Advertised routes:    192.168.10.0/24
Accept DNS:           unchecked
```
**Reference:** https://tailscale.com/kb/1298/pfsense/

---

### Generate pre-auth key for pfSense
```
https://login.tailscale.com/admin/settings/keys
→ Generate auth key
→ Reusable: No
→ Expiration: 1 day
→ Ephemeral: No
→ Generate key → copy tskey-auth-xxxxx
```
**What it does:** Creates a one-time authentication key that pfSense uses to join your Tailscale network without requiring browser-based OAuth.
**Reference:** https://tailscale.com/kb/1085/auth-keys/

---

## Tailscale Admin Panel — Subnet Route Approval

### Approve subnet routes
```
https://login.tailscale.com/admin/machines
→ Find device (proxmox or pfsense)
→ Click ... → Edit route settings
→ Enable: 192.168.30.0/24 ✓  (Proxmox)
→ Enable: 192.168.10.0/24 ✓  (pfSense)
→ Save
```
**What it does:** Approves the subnet routes advertised by each device. Without approval, other Tailscale devices cannot use the routes even if they are advertised.
**Reference:** https://tailscale.com/kb/1019/subnets/#step-3-approve-the-subnet-routes-in-the-admin-console

---

## Windows Desktop — Tailscale Commands

### Install Tailscale on Windows
```
https://tailscale.com/download/windows
→ Download installer → run → sign in
```
**Reference:** https://tailscale.com/download/windows

---

### Check Tailscale status on Windows
```powershell
tailscale status
```

### Test connectivity through Tailscale subnet routes
```powershell
ping 192.168.30.10   # Proxmox via pfSense subnet route
ping 192.168.10.1    # pfSense via pfSense subnet route
ping 192.168.30.2    # Pi-hole via Proxmox subnet route
ping 100.111.109.122 # Proxmox via Tailscale IP directly
```

---

## Mac — Tailscale Commands

### Install Tailscale on Mac
```
App Store → search Tailscale → install
OR
https://tailscale.com/download/mac
```
**Reference:** https://tailscale.com/download/mac

---

### Check status on Mac
```bash
tailscale status
```

### Test connectivity
```bash
ping 192.168.30.10
ping 192.168.10.1
curl https://192.168.30.10:8006  # Proxmox web GUI
```

---

## Verification — All Devices Connected

After setup your Tailscale network should show:
```bash
tailscale status
# Expected output:
100.111.109.122  proxmox         linux    active
100.71.210.42    pfsense         freebsd  active
100.124.83.47    tieyon-pc       windows  active
100.96.102.65    tieyon-phone    iOS      active
100.86.186.126   tieyons-laptop  macOS    active
```

---

## Key References

| Topic | URL |
|-------|-----|
| Tailscale documentation | https://tailscale.com/kb/ |
| Subnet routing setup | https://tailscale.com/kb/1019/subnets/ |
| IP forwarding Linux | https://tailscale.com/kb/1019/subnets/#enable-ip-forwarding |
| Auth keys | https://tailscale.com/kb/1085/auth-keys/ |
| pfSense Tailscale package | https://tailscale.com/kb/1298/pfsense/ |
| Tailscale CLI reference | https://tailscale.com/kb/1080/cli/ |
| UDP GRO fix | https://tailscale.com/s/ethtool-config-udp-gro |
| Tailscale admin panel | https://login.tailscale.com/admin/machines |
| Key expiry | https://tailscale.com/kb/1028/key-expiry/ |
