# 02 — pfSense Firewall

**Status:** ✅ Complete
**Skills:** VLAN segmentation, firewall rule design, DHCP, outbound NAT, remote syslog

## What This Is

pfSense CE running on a dedicated Lenovo ThinkCentre M60E. This is the core of the network — it handles routing, VLAN enforcement, DHCP, firewall rules, cross-VLAN NAT, and forwards logs to the SIEM.

## Why pfSense on Dedicated Hardware

A firewall should be a single-purpose, always-on device that isn't sharing resources or a reboot schedule with anything else. Running it on its own mini PC keeps the security boundary independent of the hypervisor. pfSense CE is free, battle-tested, and gives enterprise features (VLANs, IDS/IPS, NAT rules, syslog) on cheap hardware.

## Network Design

Two segments off the LAN interface:
- **Trusted LAN** — workstations, native on the LAN interface
- **Lab VLAN** — a tagged 802.1Q subinterface for the Proxmox/lab side

Default-deny is the baseline; each allow rule is explicit and documented in `firewall-rules` reasoning below.

## Key Configuration

- WAN pulls its address from the Slate 7 DMZ
- LAN interface hosts the trusted subnet
- A single tagged VLAN subinterface carries the lab segment
- Outbound NAT rule enables cross-VLAN DNS to Pi-hole (see ISSUES.md Issue on cross-VLAN DNS)
- Remote syslog forwards firewall/DHCP/auth/system events to Wazuh

## References

- pfSense install: https://docs.netgate.com/pfsense/en/latest/install/
- Firewall rule methodology: https://docs.netgate.com/pfsense/en/latest/firewall/rule-methodology.html
- Outbound NAT: https://docs.netgate.com/pfsense/en/latest/nat/outbound.html
- Remote logging: https://docs.netgate.com/pfsense/en/latest/monitoring/logs/remote.html
