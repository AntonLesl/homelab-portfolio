# 10 — Suricata IDS

**Status:** ✅ Complete
**Skills:** Network intrusion detection, ruleset management, IDS vs IPS tradeoffs

## What This Is

Suricata running on pfSense's LAN interface as an Intrusion Detection System, inspecting internal traffic against Emerging Threats rules and alerting on suspicious activity.

## Why Suricata (and why IDS, not IPS here)

Suricata is a high-performance, open-source IDS/IPS. It was deployed in **IDS (alert-only) mode on the LAN interface** rather than IPS mode on the WAN. The reason is hard-won: running Suricata in IPS mode on top of the USB WAN NIC froze the entire network (see ISSUES.md). Alert-only on the LAN gives visibility into east-west and outbound traffic without the throughput/stability penalty that inline blocking imposed on this hardware.

## Design

- Suricata on the pfSense LAN interface
- Emerging Threats open ruleset
- IDS (alert) mode — alerts feed into the monitoring workflow
- Hardware offloading disabled on the interface for correct inspection

## References

- Suricata on pfSense: https://docs.netgate.com/pfsense/en/latest/packages/suricata/index.html
- Suricata docs: https://docs.suricata.io/
- Emerging Threats rules: https://rules.emergingthreats.net/
