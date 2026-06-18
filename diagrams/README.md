# Diagrams

Network topology and architecture diagrams for the homelab portfolio.

---

## Full Network Topology

![Full Network Topology](./full-topology.png)

> Shows the complete homelab from ISP → Slate 7 → pfSense → managed switch → VLAN 10 (Pi-hole, laptop) and VLAN 30 (Proxmox), with the isolated cyber lab on vmbr2 and Tailscale overlay.

---

## Proxmox Bridge Design

![Proxmox Bridges](./proxmox-bridges.png)

> Shows vmbr0 (VLAN 30, management) and vmbr2 (no uplink, isolated cyber lab) inside Proxmox, and the one-way Wazuh log path out of the lab on port 1514.

---

## Switch VLAN Port Map

![Switch VLAN Map](./switch-vlan-map.png)

> 8-port switch with port 1 as trunk to pfSense, ports 2–3 as VLAN 10 access (Pi-hole, laptop), port 4 as VLAN 30 access (Proxmox), ports 5–8 spare.

---

## Cyber Lab Isolation Design

![Cyber Lab Isolation](./cyber-lab-isolation.png)

> Shows how vmbr2 enforces isolation — no physical uplink, no pfSense route, only Wazuh agent log push allowed outbound.

---

## File Index

| File | Description | Status |
|------|-------------|--------|
| `full-topology.png` | Complete homelab network topology | Add after setup |
| `proxmox-bridges.png` | Proxmox vmbr0 and vmbr2 bridge design | Add after setup |
| `switch-vlan-map.png` | 8-port switch VLAN port assignment | Add after setup |
| `cyber-lab-isolation.png` | Cyber lab isolation and traffic rules | Add after setup |

---


