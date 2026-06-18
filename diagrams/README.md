# Diagrams

| File | Description |
|------|-------------|
| `full-topology.png` | Complete homelab network topology |
| `proxmox-bridges.png` | vmbr0 and vmbr2 bridge design |
| `switch-vlan-map.png` | 8-port switch VLAN port assignment |
| `cyber-lab-isolation.png` | Cyber lab isolation and traffic rules |

## How to Add Screenshots (Mac)
```bash
# Screenshot a region
Cmd + Shift + 4 → drag to select → auto-saves to Desktop

# Move into repo
mv ~/Desktop/Screenshot*.png ~/homelab-portfolio/diagrams/full-topology.png

git add diagrams/
git commit -m "Add network topology diagram"
git push
```
