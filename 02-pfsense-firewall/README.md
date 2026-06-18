# 02 — pfSense Firewall

**Skills:** VLAN segmentation, firewall rules, Suricata IDS/IPS, DHCP hardening

## Purpose
pfSense is the network core — handles all routing, VLAN enforcement, intrusion detection, and DHCP. Nothing crosses segments without an explicit allow rule.

## Steps
1. Install pfSense CE on mini PC (2 NICs: WAN + LAN)
2. Run setup wizard — LAN: `192.168.10.1/24`
3. Create VLANs 10 (TRUSTED) and 30 (LAB) on LAN interface
4. Assign VLAN interfaces with static IPs
5. Configure DHCP on each VLAN — Pi-hole as only DNS server
6. Add static leases for Pi-hole, Proxmox, Wazuh, OpenVAS
7. Write firewall rules (see [firewall-rules.md](./firewall-rules.md))
8. Install and configure Suricata on WAN
9. Enable syslog to Wazuh at `192.168.30.20:514`

## Key Config Files
- [firewall-rules.md](./firewall-rules.md) — all rules with rationale
- [vlan-config.md](./vlan-config.md) — VLAN interface setup

## Resume Bullets
> "Deployed pfSense CE with VLAN segmentation across trusted and lab segments, enforcing zero inter-VLAN trust via explicit allow/deny ruleset"
> "Configured Suricata IDS/IPS on WAN with ET Open and Snort Community rulesets for real-time threat detection and blocking"
