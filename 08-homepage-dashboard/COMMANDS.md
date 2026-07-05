# Commands — 08 Homepage Dashboard

## Edit the services configuration

```bash
nano config/services.yaml
```
**Why:** Defines each dashboard tile — name, href, and optional status widget. Tiles use stable Tailscale addresses so they resolve remotely.
**Where learned:** https://gethomepage.dev/configs/services/

## Restart the container to apply config

```bash
docker restart homepage
```
**Why:** Config changes are picked up on restart.

## Check the container logs when a tile fails

```bash
docker logs homepage
```
**Why:** Used to diagnose the certificate/port issues below — the logs show why a widget can't reach a backend.
