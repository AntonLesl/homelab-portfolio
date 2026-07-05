# Commands — 02 pfSense Firewall

pfSense is configured mostly through its web GUI, but the shell and GUI diagnostic tools were essential during setup and troubleshooting. Each entry lists what it does, why it was used, and where it was learned.

## Identify network interfaces at the console

```
# pfSense console menu → option 1 (Assign Interfaces)
```
**Why:** The M60E only has one onboard NIC, so a USB ethernet adapter was added for the second interface. The console interface assignment step is where you map physical NICs (e.g. `re0`, `ue0`) to WAN/LAN roles.
**Where learned:** https://docs.netgate.com/pfsense/en/latest/install/assign-interfaces.html

## Check an interface's MAC and status from the shell

```sh
ifconfig <lan_interface>
```
**Why:** Used to read the MAC address after swapping the USB adapter — the MAC change was what broke the Proxmox ARP entry (documented in Proxmox ISSUES.md).
**Where learned:** FreeBSD ifconfig manual — https://man.freebsd.org/cgi/man.cgi?ifconfig

## Packet capture to trace cross-VLAN DNS

```
Diagnostics → Packet Capture → interface: LAN → protocol UDP → port 53
```
**Why:** DNS from the trusted LAN to Pi-hole (on the lab VLAN) was timing out. The capture proved packets left the client and reached pfSense but were not being forwarded — narrowing the problem to NAT + Pi-hole listening mode.
**Where learned:** https://docs.netgate.com/pfsense/en/latest/diagnostics/packetcapture.html

## Outbound NAT rule for cross-VLAN DNS (GUI)

```
Firewall → NAT → Outbound → Hybrid mode → Add
Interface: LAN
Protocol: TCP/UDP
Source: [trusted LAN subnet]
Destination: [DNS server IP] port 53
Translation: LAN interface address
```
**Why:** When a trusted-LAN client queries Pi-hole on the lab VLAN, Pi-hole sees a foreign source subnet and its default route can't reply correctly. Translating the source to the firewall's own LAN address makes Pi-hole reply to the firewall, which forwards it back to the client.
**Where learned:** https://docs.netgate.com/pfsense/en/latest/nat/outbound.html

## Remote syslog to the SIEM (GUI)

```
Status → System Logs → Settings
Enable Remote Logging → remote server [SIEM IP]:514 → UDP
Log: Firewall Events, DHCP, System, Authentication
```
**Why:** Forwarding firewall events to Wazuh enables correlation — blocked connections, DHCP leases, and auth attempts all become searchable and can trigger detection rules.
**Where learned:** https://docs.netgate.com/pfsense/en/latest/monitoring/logs/remote.html

## Interface reload (temporary USB NIC workaround)

```
Services → Cron → Add
Command: /usr/local/sbin/pfSctl -c 'interface reload <lan_interface>'
```
**Why:** The USB LAN adapter periodically dropped link. A cron that reloads the interface (and a nightly reboot) kept the network alive until a PCIe NIC could replace it. See ISSUES.md.
