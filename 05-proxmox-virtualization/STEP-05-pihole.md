# Step 5 — Pi-hole + DNS over HTTPS

## What you need
- Proxmox running (Step 4 complete)
- Ubuntu 22.04 LXC template downloaded

---

## 5.1 — Create Pi-hole LXC container

In Proxmox web UI → Create CT (top right button):

```
General:
  CT ID:        100
  Hostname:     pihole
  Password:     (set a strong password)
  Unprivileged: ✓ checked

Template:
  Storage:      local
  Template:     ubuntu-22.04-standard

Disks:
  Storage:      local-lvm
  Size:         8 GB

CPU:
  Cores:        1

Memory:
  Memory:       512 MB
  Swap:         512 MB

Network:
  Name:         eth0
  Bridge:       vmbr0
  VLAN Tag:     10
  IPv4:         Static
  IPv4/CIDR:    192.168.10.2/24
  Gateway:      192.168.10.1

DNS:
  DNS domain:   local
  DNS servers:  1.1.1.1
```

Click Finish → Start container.

---

## 5.2 — Open LXC console

In Proxmox → click container 100 (pihole) → Console.

Login as root with the password you set.

---

## 5.3 — Update and install Pi-hole

```bash
# Update system
apt update && apt upgrade -y

# Install Pi-hole
curl -sSL https://install.pi-hole.net | bash
```

**During the Pi-hole installer:**
```
Network interface:    eth0
Upstream DNS:         Custom
Custom DNS:           127.0.0.1#5053    ← Cloudflared (set up next)
Block lists:          Keep defaults (press OK)
Admin web interface:  Yes
Enable logging:       Yes
Privacy mode:         Show everything
```

After install completes, set admin password:
```bash
pihole -a -p
```

Choose a strong password. Write it down.

Access Pi-hole admin panel from your laptop:
```
http://192.168.10.2/admin
```

---

## 5.4 — Install Cloudflared (DNS over HTTPS)

Still in the Pi-hole console:

```bash
# Download cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb

# Create config directory
mkdir -p /etc/cloudflared

# Write config file
cat > /etc/cloudflared/config.yml << 'EOF'
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
EOF

# Install as system service and start
cloudflared service install
systemctl enable cloudflared
systemctl start cloudflared

# Verify it is working
dig @127.0.0.1 -p 5053 google.com
```

You should see a valid DNS response. If so, DNS over HTTPS is working.

---

## 5.5 — Point Pi-hole upstream DNS to Cloudflared

In Pi-hole admin panel → Settings → DNS:

```
Upstream DNS:
  Uncheck ALL preset providers (Google, Cloudflare, etc.)

Custom DNS (IPv4):
  127.0.0.1#5053
```

Click Save.

**Verify the chain works:**
```bash
# From Pi-hole console
dig @127.0.0.1 google.com
# Should resolve via Pi-hole → Cloudflared → 1.1.1.1 over HTTPS
```

---

## 5.6 — Add threat blocklists

In Pi-hole admin panel → Group Management → Adlists → Add:

Add each URL one at a time:
```
https://big.oisd.nl
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://urlhaus.abuse.ch/downloads/rpz/
https://raw.githubusercontent.com/nicehash/sharkseeds/master/dns-malware.txt
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
```

After adding all lists, update gravity:

```bash
# In Pi-hole console
pihole -g
```

This takes 2–5 minutes. When done check the dashboard — you should see 1M+ domains blocked.

---

## 5.7 — Enable conditional forwarding

Settings → DNS → Advanced DNS settings:

```
Use conditional forwarding:   ✓ checked
Local network:                192.168.0.0/16
IP of your DHCP server:       192.168.10.1
Local domain name:            homelab.local
```

Save.

---

## 5.8 — Add Pi-hole static lease to pfSense

Now that Pi-hole is running, go to pfSense web UI:

Services → DHCP Server → TRUSTED → Static Mappings → Add:

First get Pi-hole's MAC address:
```bash
# In Pi-hole console
ip link show eth0
# Copy the MAC address (format: aa:bb:cc:dd:ee:ff)
```

In pfSense:
```
MAC Address:   (paste Pi-hole MAC)
IP Address:    192.168.10.2
Hostname:      pihole
Description:   Pi-hole DNS
```

Save.

---

## 5.9 — Verify DNS is working for all clients

From your laptop (connected to switch port 3 on VLAN 10):

```bash
# Check DNS server being used
nslookup google.com
# Server should show: 192.168.10.2

# Test a blocked domain
nslookup doubleclick.net
# Should return: 0.0.0.0 (blocked)

# Test internet still works
curl -I https://google.com
# Should return HTTP 301
```

Check Pi-hole dashboard — you should see your laptop's queries appearing in Query Log.

---

## 5.10 — Screenshots for GitHub

Take screenshots of:
- Pi-hole dashboard showing domain block count and query activity
- Settings → DNS showing upstream pointing to 127.0.0.1#5053
- Query log showing blocked domains
- Adlists page showing all blocklists added

Save to:
```
homelab-portfolio/04-pihole-dns/screenshots/
```

---

## Done — move to Step 6
