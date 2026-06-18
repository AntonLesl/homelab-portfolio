# Cyber Lab Network Design

## Why vmbr2 with no uplink?

The cyber lab uses a Proxmox internal bridge (`vmbr2`) with `bridge-ports none`. This means:
- No physical NIC is attached
- pfSense has no interface into 10.10.10.0/24
- There is no route out — not even through the hypervisor host
- The only exception is the static route added in `/etc/network/interfaces` for Wazuh log shipping

This is isolation enforced at the hypervisor level, not just firewall rules. Even if pfSense were misconfigured, the lab VMs still cannot reach the outside.

## /etc/hosts on all lab VMs
```
10.10.10.5    kali
10.10.10.10   dc01 dc01.lab.local
10.10.10.20   win10 win10.lab.local
10.10.10.30   metasploitable
```

## Wazuh Agent Config on Lab VMs
Each lab VM runs a Wazuh agent pointing to `192.168.30.20:1514`.
The agent initiates outbound — management network never initiates inbound to lab.
