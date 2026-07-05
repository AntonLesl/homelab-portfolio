# Commands — 04 Proxmox VE

## Define the bridges in the interfaces file

```bash
nano /etc/network/interfaces
```
**Why:** vmbr0 (services, with uplink) and vmbr2 (isolated lab, no uplink) are declared here. Leaving vmbr2 without a `bridge-ports` uplink is what makes the lab air-gapped.
**Where learned:** https://pve.proxmox.com/wiki/Network_Configuration

## Apply network changes without rebooting

```bash
ifreload -a
```
**Why:** Reloads the bridge configuration after editing `/etc/network/interfaces`.
**Where learned:** Proxmox network docs (ifupdown2).

## Enable IP forwarding (for subnet routing via Tailscale)

```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```
**Why:** Required for Proxmox to route traffic for the subnet-router role (see Tailscale section). Without it, advertised routes don't actually forward. This kept getting reset, hence writing it to sysctl.conf.
**Where learned:** https://tailscale.com/kb/1019/subnets/

## Fix a lost gateway ARP entry (permanent)

```bash
ip neigh replace [gateway ip] lladdr [firewall LAN MAC] dev vmbr0 nud permanent
```
**Why:** After the pfSense USB adapter was swapped, its MAC changed. Proxmox held the old MAC in ARP and couldn't reach the gateway. A permanent ARP entry pins the correct MAC. See ISSUES.md.
**Where learned:** https://man7.org/linux/man-pages/man8/ip-neighbour.8.html

## Inspect the ARP/neighbor table

```bash
ip neigh show
```
**Why:** Used to see the FAILED entry for the gateway during the ARP troubleshooting.
