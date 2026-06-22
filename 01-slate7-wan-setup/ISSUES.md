# Issues — 01 GL.iNet Slate 7 WAN Setup

---

## Issue 001 — Could not access admin portal at 192.168.8.1

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
Browser timed out when navigating to `http://192.168.8.1`. Page would not load at all — just spun and failed.

### Root Cause
Laptop was still connected to AT&T home Wi-Fi network (`192.168.1.x` subnet). The Slate 7 admin portal lives at `192.168.8.1` which is on a completely different subnet. A device on `192.168.1.x` cannot reach `192.168.8.x` without a route between them — which doesn't exist.

### How I Fixed It
Connected laptop to the Slate 7 Wi-Fi network first:
1. Clicked Wi-Fi icon in taskbar
2. Found the GL-XXXX network (name printed on label on bottom of Slate 7)
3. Connected using the default Wi-Fi password also on the label
4. Ran `ipconfig` — confirmed laptop now showed `192.168.8.x` IP
5. Opened browser → `http://192.168.8.1` — loaded immediately

### Lesson Learned
You must be connected to the target device's own network before you can reach its management interface. This applies everywhere — switches, routers, APs — always verify your IP is in the same subnet as the management address before troubleshooting further.

### Verification
```powershell
ipconfig
# Confirmed: IPv4 Address 192.168.8.x
# Then: http://192.168.8.1 loaded successfully
```

---

*No further issues encountered on this step.*
