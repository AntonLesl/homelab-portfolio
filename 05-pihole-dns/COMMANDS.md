# Commands — 05 Pi-hole + Unbound

## Install Pi-hole

```bash
curl -sSL https://install.pi-hole.net | bash
```
**Why:** Official one-line installer for Pi-hole inside the LXC.
**Where learned:** https://docs.pi-hole.net/main/basic-install/

## Install Unbound recursive resolver

```bash
apt install unbound -y
```
**Why:** Provides local recursive DNS so Pi-hole resolves from root servers instead of forwarding to a public DNS provider.
**Where learned:** https://docs.pi-hole.net/guides/dns/unbound/

## Check / fix Pi-hole listening mode

```bash
grep -i "ListeningMode" /etc/pihole/pihole.toml
```
**Why:** Pi-hole v6 defaults to `ListeningMode = "LOCAL"`, which rejects queries from other subnets. Cross-VLAN clients need `"all"`. This was the root cause of cross-VLAN DNS failing. See ISSUES.md.
**Where learned:** https://docs.pi-hole.net/ (v6 configuration)

## Verify DNS resolution end to end

```bash
dig google.com @[pihole ip]
```
**Why:** Confirms Pi-hole answers and Unbound resolves recursively.
**Where learned:** https://linux.die.net/man/1/dig
