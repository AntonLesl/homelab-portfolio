# 01 — GL.iNet Slate 7 WAN Setup

**Skills:** DMZ mode, WAN passthrough, travel router hardening

## Purpose
The Slate 7 receives the public IP from the ISP and forwards it directly to pfSense via DMZ mode, eliminating double-NAT and giving pfSense true edge visibility.

## Steps
1. Connect ISP modem LAN → Slate 7 WAN port
2. Access admin panel at `http://192.168.8.1`
3. Go to **More Settings → Network → DMZ** → enable → set target to `192.168.8.2` (pfSense WAN)
4. Connect Slate 7 LAN → pfSense WAN NIC
5. Harden: disable cloud services, change admin password, disable unused Wi-Fi

## Verification
| Check | Expected |
|-------|---------|
| Slate 7 WAN | Public ISP IP |
| pfSense WAN | 192.168.8.2 |
| DMZ active | All traffic forwarded to pfSense |

## Screenshots
See [`screenshots/`](./screenshots/)

## Resume Bullet
> "Configured GL.iNet Slate 7 as WAN entry with DMZ forwarding to pfSense, eliminating double-NAT and enabling full edge firewall source IP visibility"
