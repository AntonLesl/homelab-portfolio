# 01 — GL.iNet Slate 7 WAN Setup

**Status:** ✅ Complete
**Skills:** DMZ mode, WAN passthrough, router hardening

## What This Is

The GL.iNet Slate 7 is the WAN entry point. It connects to the ISP and passes all inbound traffic straight to the pfSense firewall using DMZ mode.

## Why DMZ Mode

Most home ISP setups create double-NAT: the ISP gateway does NAT, then a second router does NAT again. Double-NAT breaks certain protocols, hides real source IPs from firewall logs, and complicates port forwarding. Putting the Slate 7 in DMZ mode forwards all inbound traffic to a single target (the firewall's WAN NIC), so pfSense becomes the single NAT boundary and sees real source addresses.

## Physical Wiring

```
ISP Modem LAN → Slate 7 WAN → Slate 7 LAN → pfSense WAN NIC
```

## Steps

1. Access the Slate 7 admin portal, change the admin password immediately
2. Internet → confirm a public ISP IP is visible on the WAN
3. Network → DMZ → enable → point it at the firewall's WAN address
4. Harden: disable cloud/remote management, disable SSH, disable unused Wi-Fi radios

## Verification

| Check | Expected |
|-------|----------|
| Slate 7 WAN | Public ISP IP |
| DMZ enabled | ON, targeting the firewall WAN |
| Firewall WAN | Pulls the DMZ address |

## Reference

- GL.iNet DMZ docs: https://docs.gl-inet.com/
