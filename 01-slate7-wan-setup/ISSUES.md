# Issues — 01 GL.iNet Slate 7 WAN Setup

---

## Issue 001 — Could not access the Slate 7 admin portal

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
Browser timed out loading the Slate 7 admin portal. The page just spun and failed.

### Root Cause
The laptop was still connected to the existing home Wi-Fi, which sits on a different subnet than the Slate 7. A client can only reach the router's admin portal when it's on the router's own subnet.

### Investigation
```powershell
ipconfig
# Showed the laptop on the home Wi-Fi subnet, not the Slate 7 subnet
```

### How I Fixed It
Connected the laptop directly to the Slate 7 (Wi-Fi or LAN port), released/renewed DHCP, confirmed the client picked up an address on the router's subnet, then loaded the portal successfully.

```powershell
ipconfig /release
ipconfig /renew
```

### Lesson Learned
To reach any appliance's management interface you must be on its management subnet. Always check `ipconfig` before assuming the device is broken.
