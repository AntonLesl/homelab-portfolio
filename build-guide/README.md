# Build Guide — Step by Step

Complete terminal commands and directions for building the entire homelab in the correct order.

> **Pi-hole = VM on Proxmox (CT 100, VLAN 10)**
> **pfSense = separate physical device**

## Build Order

| File | Steps | Covers |
|------|-------|--------|
| [01-slate7-setup.md](./01-slate7-setup.md) | Step 1 | Slate 7 WAN + DMZ config |
| [02-pfsense-setup.md](./02-pfsense-setup.md) | Step 2 | pfSense VLANs, DHCP, firewall rules |
| [03-switch-setup.md](./03-switch-setup.md) | Step 3 | Managed switch 802.1Q config |
| [04-proxmox-setup.md](./04-proxmox-setup.md) | Step 4 | Proxmox install + vmbr0/vmbr2 |
| [05-pihole-setup.md](./05-pihole-setup.md) | Step 5 | Pi-hole VM + Cloudflared DoH |
| [06-tailscale-setup.md](./06-tailscale-setup.md) | Step 6 | Tailscale subnet routing |
| [07-wazuh-setup.md](./07-wazuh-setup.md) | Step 7 | Wazuh SIEM + custom rules |
| [08-11-cyberlab-setup.md](./08-11-cyberlab-setup.md) | Steps 8–11 | DC, Win10, Kali, Metasploitable |
| [12-14-final.md](./12-14-final.md) | Steps 12–14 | Suricata, OpenVAS, 5 attack exercises |

Follow files in order — each step depends on the one before it.
