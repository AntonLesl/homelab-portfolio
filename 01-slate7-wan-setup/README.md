# 01 — GL.iNet Slate 7 WAN Setup
**Skills:** DMZ mode, WAN passthrough, router hardening

## Physical Wiring
```
ISP Modem LAN → Slate 7 WAN → Slate 7 LAN → pfSense WAN NIC
```

## Steps
1. Access `http://192.168.8.1` — change admin password immediately
2. Internet → Cable — confirm public ISP IP visible
3. More Settings → Network → DMZ → enable → target `192.168.8.2`
4. Disable: cloud services, SSH, unused Wi-Fi

## Verification
| Check | Expected |
|-------|---------|
| Slate 7 WAN | Public ISP IP |
| DMZ enabled | ON → 192.168.8.2 |
| pfSense WAN | 192.168.8.2 |

## Resume Bullet
> "Configured GL.iNet Slate 7 as WAN entry with DMZ forwarding to pfSense, eliminating double-NAT"
