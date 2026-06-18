# Pi-hole Blocklists

| List | URL | Focus |
|------|-----|-------|
| OISD Full | https://big.oisd.nl | Ads, trackers, malware |
| Steven Black | https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | Ads + social |
| URLhaus | https://urlhaus.abuse.ch/downloads/rpz/ | Malware URLs |
| Dandelion Anti-Malware | DandelionSprout repo | Malware domains |

## Anomalies to Watch in Query Log
- Queries to `.xyz` `.top` `.tk` (high-abuse TLDs)
- Long random-character subdomains (DNS tunneling / C2)
- High query rate from a single host at unusual hours
