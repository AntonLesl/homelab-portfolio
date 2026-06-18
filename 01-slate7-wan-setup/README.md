# 01 — GL.iNet Slate 7 WAN Setup

**Skills:** DMZ mode, WAN passthrough, travel router hardening

## Purpose
The Slate 7 receives the public IP from the ISP and forwards it directly to pfSense using DMZ mode, eliminating double-NAT so pfSense has true edge visibility.

## Physical Wiring
```
ISP Modem LAN → Slate 7 WAN port → Slate 7 LAN port → pfSense WAN NIC
```

## Key Steps
1. Access admin at `http://192.168.8.1` — change password immediately
2. Verify WAN shows public ISP IP: Internet → Cable
3. Enable DMZ: More Settings → Network → DMZ → target `192.168.8.2`
4. Harden: disable cloud services, SSH, unused Wi-Fi

## Verification
| Check | Expected |
|-------|---------|
| Slate 7 WAN | Public ISP IP |
| DMZ enabled | ON → 192.168.8.2 |
| pfSense WAN | 192.168.8.2 |

## Screenshots
See [`screenshots/`](./screenshots/)

## Resume Bullet
> "Configured GL.iNet Slate 7 as WAN entry with DMZ forwarding to pfSense, eliminating double-NAT and enabling full edge firewall source IP visibility"
