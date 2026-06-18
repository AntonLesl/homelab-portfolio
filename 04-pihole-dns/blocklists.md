# Pi-hole Blocklists

| List | URL | Focus |
|------|-----|-------|
| OISD Full | https://big.oisd.nl | Ads, trackers, malware |
| Steven Black | https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | Ads + social |
| URLhaus | https://urlhaus.abuse.ch/downloads/rpz/ | Malware URLs |
| Anti-Malware | Dandelion Sprout | Malware domains |

## DNS Anomalies to Monitor
- Queries to `.xyz`, `.top`, `.tk` high-abuse TLDs
- Long random-character subdomains (DNS tunneling / C2)
- High query rate from single host at unusual hours
