# Proxmox + Tailscale Remote Access Topology

```text
                    Anywhere Internet
                           |
                    Tailscale control plane
                  login.tailscale.com / DERP
                           |
        +------------------+------------------+
        |                                     |
+-------------------+                 +-------------------+
| Remote laptop     |                 | Phone / tablet    |
| macOS Tailscale   |                 | Tailscale app     |
| Tailnet client    |                 | Tailnet client    |
+---------+---------+                 +---------+---------+
          |                                     |
          +------------------+------------------+
                             |
                       Tailscale mesh
                             |
                    100.112.238.38
                    pve.tailc2b3f5.ts.net
                             |
+----------------------------------------------------------+
| Proxmox VE host: pve                                    |
| tailscaled running on host                              |
| pveproxy listening on HTTPS port 8006                   |
| Proxmox UI: https://100.112.238.38:8006                 |
| Optional MagicDNS: https://pve.tailc2b3f5.ts.net:8006   |
+----------------------------------------------------------+
                             |
                       vmbr0 / LAN
                             |
          +------------------+------------------+
          |                                     |
      VM / LXC                              VM / LXC
```

## Security model

- Do not port-forward Proxmox port 8006 from your router.
- Access Proxmox only over Tailscale.
- Tailscale must be installed and logged in on both:
  - the Proxmox host
  - the remote laptop/phone
- Proxmox web UI runs on port 8006 through `pveproxy`.
- Tailscale MagicDNS requires Tailscale DNS to be enabled on the client.
