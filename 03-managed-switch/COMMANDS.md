# Commands — 03 Managed Switch

The GS308E is configured through its web UI, so most work is menu-driven. These are the client-side commands used to verify VLAN behavior and the reasoning for each.

## Statically pin a client IP for switch access

```powershell
netsh interface ip set address "Ethernet" static [ip] [mask] [gateway]
```
**Why:** The GS308E web UI lives on a fixed management IP. To reach it during initial config (before DHCP is sorted per VLAN), pin the client to the switch's subnet.
**Where learned:** https://learn.microsoft.com/windows-server/networking/technologies/netsh/netsh

## Return the client to DHCP after VLAN config

```powershell
netsh interface ip set address "Ethernet" dhcp
ipconfig /renew
```
**Why:** Once ports and PVIDs are set, the device should pull its address from pfSense DHCP on its assigned VLAN.

## Verify the client landed on the right VLAN

```powershell
ipconfig /release
ipconfig /renew
ipconfig
```
**Why:** The gateway and subnet in the output confirm which VLAN the access port actually placed the device on. Wrong gateway = wrong PVID/membership.

## Test connectivity and internet after VLAN cutover

```powershell
ping [firewall gateway]
ping 8.8.8.8
```
**Why:** Confirms the access port reaches its gateway and out to the internet — the fast check that trunking is working end to end.
