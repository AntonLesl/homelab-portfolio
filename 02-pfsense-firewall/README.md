# 02 — pfSense Firewall
**Skills:** VLAN segmentation, firewall rules, Suricata IDS/IPS, DHCP hardening

## Purpose
Separate physical device. Core firewall handling routing, VLAN enforcement, IDS/IPS, DHCP.

## Steps
1. Install pfSense CE on mini PC (2 NICs: WAN + LAN)
2. Setup wizard — LAN: `192.168.10.1/24`
3. Create VLAN 10 (TRUSTED) and VLAN 30 (LAB)
4. Configure DHCP — Pi-hole VM `192.168.10.2` as only DNS server
5. Add firewall rules — see [firewall-rules.md](./firewall-rules.md)
6. Enable syslog to Wazuh `192.168.30.20:514`
7. Install Suricata on WAN (do this last at Step 12)

## Config Files
- [firewall-rules.md](./firewall-rules.md)
- [vlan-config.md](./vlan-config.md)

## Resume Bullets
> "Deployed pfSense CE with VLAN segmentation enforcing zero inter-VLAN trust via explicit allow/deny ruleset"
> "Configured Suricata IDS/IPS on WAN with ET Open rulesets for real-time threat detection"
