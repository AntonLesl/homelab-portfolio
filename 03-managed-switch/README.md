# 03 — Netgear GS308E Managed Switch

**Status:** ✅ Complete
**Skills:** 802.1Q VLAN trunking, access/tagged ports, PVID, port membership

## What This Is

A Netgear GS308E managed switch carrying both the trusted LAN and the lab VLAN over a single trunk to pfSense, then breaking them out to access ports for individual devices.

## Why a Managed Switch

An unmanaged switch can't separate VLANs. To carry two segments (trusted + lab) over one cable to the firewall and deliver each to the right device, you need 802.1Q VLAN tagging — which requires a managed switch.

## Port Design

```
Port 1  — Tagged trunk to pfSense (carries all VLANs)
Port 3  — Untagged trusted LAN (workstation)   · PVID = trusted
Port 4  — Untagged lab VLAN (Proxmox)          · PVID = lab
```

The trunk port is **tagged** for every VLAN it carries. Each access port is **untagged** for exactly one VLAN, and its **PVID** matches that VLAN so untagged frames from the device get placed on the right segment.

## Critical Lesson

This switch must run in **Advanced 802.1Q mode**, not Basic. See ISSUES.md — Basic mode broke all ethernet.

## Reference

- Netgear GS308E 802.1Q VLAN configuration: https://www.netgear.com/support/product/gs308e/
- 802.1Q overview: https://en.wikipedia.org/wiki/IEEE_802.1Q
