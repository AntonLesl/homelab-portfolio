# Scripts

These scripts support the Plex + Proxmox + Tailscale homelab project.

## Privacy / Sanitization

These scripts avoid hard-coding personal details such as:

- Real Tailscale IP addresses
- Real device names
- Personal usernames
- Machine identifiers
- MAC addresses

Some scripts may display private network information when run. Review command output before posting screenshots or logs publicly.

## Scripts

| Script | Run Location | Purpose |
|---|---|---|
| `verify-plex.sh` | Plex LXC container | Checks Plex process, port 32400, and local API |
| `enable-ip-forwarding.sh` | Proxmox host | Enables IPv4 forwarding for subnet routing |
| `configure-tailscale-route.sh` | Proxmox host | Advertises a LAN subnet through Tailscale |
| `network-diagnostics.sh` | Host or container | Collects IP, route, forwarding, and port info |
| `check-proxmox-container.sh` | Proxmox host | Shows LXC list and config for a selected CTID |
| `test-remote-plex.sh` | Laptop/client | Tests Plex remotely using the Plex LAN IP over Tailscale |

## Example Flow

```bash
# On Proxmox host
./enable-ip-forwarding.sh
LAN_SUBNET="192.168.x.0/24" ./configure-tailscale-route.sh
./check-proxmox-container.sh 100

# Inside Plex container
./verify-plex.sh

# From laptop/client
./test-remote-plex.sh 192.168.x.x
```

## Notes

For a public GitHub portfolio, use placeholders such as:

- `192.168.x.x`
- `100.x.x.x`
- `<CTID>`
- `<TAILNET-NAME>`

Avoid publishing real IP addresses, hostnames, MAC addresses, or machine identifiers.
