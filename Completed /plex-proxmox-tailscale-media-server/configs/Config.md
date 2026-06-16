# Configuration Reference

## Proxmox Host Configuration

### Virtualization Platform

```text
Platform: Proxmox VE
Container Type: LXC
Container ID: <CTID>
```

### Resource Allocation

```text
CPU: 2 vCPU
Memory: 2 GB
Swap: 512 MB
Storage: 8 GB
```

### Container Features

```text
nesting=1
keyctl=1
```

### Network Bridge

```text
Bridge: vmbr0
IP Assignment: DHCP
Container Type: Unprivileged
```

---

## Plex Container Configuration

### Operating System

```text
Ubuntu Linux
```

### Plex Installation Path

```text
/usr/lib/plexmediaserver/
```

### Plex Service Verification

```bash
ps -ef | grep -i plex
```

### Listening Port

```text
32400/TCP
```

Verification:

```bash
ss -tlnp | grep 32400
```

### Plex API Test

```bash
curl http://localhost:32400/identity
```

Expected Response:

```text
MediaContainer
```

---

## Tailscale Configuration

### Installation Location

```text
Proxmox Host
```

### Advertised Route

```text
<LAN-SUBNET>/24
```

### Route Advertisement Command

```bash
tailscale up --reset --advertise-routes=<LAN-SUBNET>/24 --ssh
```

### Route Approval

```text
Tailscale Admin Console
```

---

## Linux Routing Configuration

### Verify IPv4 Forwarding

```bash
sysctl net.ipv4.ip_forward
```

### Enable IPv4 Forwarding

```bash
sysctl -w net.ipv4.ip_forward=1
```

### Persist Configuration

```bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

---

## Network Verification Commands

### View Interfaces

```bash
ip a
```

### View Assigned Addresses

```bash
hostname -I
```

### View Routes

```bash
ip route
```

### View Listening Ports

```bash
ss -tlnp
```

---

## Validation Checklist

### Plex

```text
[ ] Plex process running
[ ] Port 32400 listening
[ ] Local API responds
```

### Proxmox

```text
[ ] Container running
[ ] Bridge attached
[ ] Resources allocated
```

### Tailscale

```text
[ ] VPN connected
[ ] Route advertised
[ ] Route approved
```

### Networking

```text
[ ] IPv4 forwarding enabled
[ ] Container reachable
[ ] Remote access functional
```
