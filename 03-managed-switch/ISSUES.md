# Issues — 03 Managed Switch

---

## Issue 001 — Basic 802.1Q trunk mode broke ALL ethernet (the big one)

**Status:** ✅ Resolved
**Severity:** Critical
**Time to resolve:** 2+ hours

### Symptom
After enabling VLAN trunking in the switch's Basic 802.1Q mode, every wired device lost connectivity. No device could reach its gateway or the internet.

### Root Cause
In Basic 802.1Q mode the GS308E sends **tagged** frames out of access ports. Ordinary PC/server NICs don't understand VLAN tags — they silently drop tagged frames. So every device connected to an "access" port received traffic it couldn't process and went dark.

### Investigation
```powershell
ipconfig        # no gateway / APIPA address on affected devices
ping [gateway]  # request timed out on every wired host
```
Cross-checked the switch VLAN mode and confirmed it was Basic, not Advanced.

### How I Fixed It
1. Factory reset the switch
2. Switched to **Advanced 802.1Q** mode
3. Set the pfSense uplink port as **Tagged** for all VLANs (a real trunk)
4. Set each device port as **Untagged** for exactly one VLAN
5. Set each access port's **PVID** to match its VLAN
6. Returned clients to DHCP and verified addressing

### Lesson Learned
On a GS308E, Basic 802.1Q mode is unsuitable for a trunk-to-firewall design because it tags access-port egress. **Advanced 802.1Q** with explicit Tagged (trunk) and Untagged (access) membership plus correct PVIDs is required. This is the single most important lesson in the whole build.

---

## Issue 002 — "Failed to set Management VLAN ID with empty VLAN"

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 5 minutes

### Symptom
Error when saving port configuration referencing a VLAN.

### Root Cause
Tried to assign ports to a VLAN before that VLAN had been created.

### How I Fixed It
Created the VLAN first under the Edit VLAN screen, then assigned port membership and PVIDs.

### Lesson Learned
Create VLANs before assigning ports to them. Order of operations matters in the GS308E UI.
