# 04 — Proxmox VE Virtualization

**Status:** ✅ Complete
**Skills:** Type-1 hypervisor, Linux bridges, VLAN-aware networking, LXC + KVM lifecycle, network isolation

## What This Is

Proxmox VE is the hypervisor hosting every virtual service and the entire cyber lab. It uses two Linux bridges to enforce a hard separation between production services and the attack lab.

## Why Proxmox

Proxmox VE is a free, open-source Type-1 hypervisor with first-class support for both LXC containers (lightweight services like Pi-hole) and full KVM VMs (Windows Server, Kali). Its bridge networking model makes it easy to build an isolated lab network with no uplink — critical for safely detonating malware and running attacks.

## Bridge Design

- **vmbr0 — management/services bridge.** Connected to the lab VLAN, carries Pi-hole, Wazuh, OpenVAS, and the dashboard. Has an uplink and internet.
- **vmbr2 — isolated lab bridge.** **No physical uplink.** Windows Server DC, Windows 10 victim, Kali attacker, and Metasploitable live here. Traffic can never leave the host except Wazuh agent logs.

This "air-gapped by bridge design" approach means offensive activity is contained to a virtual switch with no path to the real network.

## References

- Proxmox VE install: https://pve.proxmox.com/wiki/Installation
- Proxmox network configuration: https://pve.proxmox.com/wiki/Network_Configuration
- Linux bridges: https://pve.proxmox.com/pve-docs/chapter-sysadmin.html#sysadmin_network_configuration
