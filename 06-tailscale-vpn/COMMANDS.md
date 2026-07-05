# Commands — 06 Tailscale VPN

## Install Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```
**Why:** Official installer for the Tailscale client on Linux (Proxmox).
**Where learned:** https://tailscale.com/download/linux

## Bring up as a subnet router (Proxmox)

```bash
tailscale up --advertise-routes=[internal subnet CIDR] --ssh --accept-dns=false
```
**Why:** Advertises the internal subnet so remote devices reach internal services without each running Tailscale. `--accept-dns=false` avoids overriding local DNS (Pi-hole). Note: `--accept-routes` is deliberately NOT used here — see ISSUES.md.
**Where learned:** https://tailscale.com/kb/1019/subnets/

## Enable the service on boot

```bash
systemctl enable tailscaled
```
**Why:** Ensures the tunnel comes back after a reboot.

## Enable IP forwarding (prerequisite for subnet routing)

```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```
**Why:** A subnet router must forward packets between the tailnet and the LAN. Without this, advertised routes don't forward.
**Where learned:** https://tailscale.com/kb/1019/subnets/

## Check tailnet status

```bash
tailscale status
```
**Why:** Confirms peers, advertised routes, and connectivity.
