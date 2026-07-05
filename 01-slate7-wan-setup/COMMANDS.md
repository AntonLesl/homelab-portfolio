# Commands — 01 Slate 7 WAN Setup

Most of the Slate 7 work is done in its web UI. These are the verification commands run from a client and the reasoning behind each.

## Confirm which network the client is on

```powershell
ipconfig
```
**Why:** Before you can reach the Slate 7 admin portal you must be on its subnet. The admin portal is unreachable from any other subnet. This was the exact cause of Issue 001.
**Where learned:** Standard Windows networking — https://learn.microsoft.com/windows-server/administration/windows-commands/ipconfig

## Release and renew DHCP after moving networks

```powershell
ipconfig /release
ipconfig /renew
```
**Why:** After plugging into the Slate 7 LAN, force a new lease so the client picks up an address on the router's subnet instead of holding a stale lease.

## Confirm the public IP is reaching the WAN

```powershell
ping 8.8.8.8
```
**Why:** Confirms upstream connectivity through the Slate 7 before layering pfSense behind it.
