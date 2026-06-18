# Pi-hole Blocklists

## Active Blocklists

| List | Source | Focus |
|------|--------|-------|
| OISD Full | `https://big.oisd.nl` | Ads, trackers, malware |
| Steven Black | `https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts` | Ads + social |
| URLhaus | `https://urlhaus.abuse.ch/downloads/rpz/` | Malware URLs |
| Anti-Malware | Dandelion Sprout | Malware domains |

## Stats
- Total domains blocked: ~1.2 million
- Query volume: update this after Pi-hole is live

## DNS Anomalies to Watch
- Repeated queries to unknown `.xyz`, `.top`, `.tk` domains (high abuse TLDs)
- Long random-character subdomains (possible DNS tunneling / C2 beaconing)
- High query rate from a single host at unusual hours
