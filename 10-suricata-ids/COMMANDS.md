# Commands — 10 Suricata IDS

Suricata on pfSense is managed through the GUI package, but these shell checks were used during setup and troubleshooting.

## Disable hardware offloading (prerequisite for correct inspection)

```
System → Advanced → Networking → check "Disable hardware checksum offload"
```
**Why:** With offloading on, the NIC modifies packets before Suricata inspects them, causing false negatives/positives. Disabling it lets Suricata see true packets.
**Where learned:** https://docs.netgate.com/pfsense/en/latest/packages/suricata/setup.html

## Watch Suricata alerts

```sh
tail -f /var/log/suricata/suricata*/fast.log
```
**Why:** Confirms rules are loaded and firing on test traffic.
**Where learned:** https://docs.suricata.io/en/latest/output/eve/eve-json-format.html

## Update the ruleset

```
Services → Suricata → Updates → Update
```
**Why:** Pulls the latest Emerging Threats signatures. Rules must be enabled by category before they alert.
**Where learned:** https://docs.netgate.com/pfsense/en/latest/packages/suricata/rules.html
