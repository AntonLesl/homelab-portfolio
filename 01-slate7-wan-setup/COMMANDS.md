# Commands — 01 GL.iNet Slate 7 WAN Setup

All commands and steps used during Slate 7 setup with explanations and references.

---

## Windows — Network Verification

### Check current IP address
```powershell
ipconfig
```
**What it does:** Shows all network adapters and their IP addresses. Used to verify laptop is connected to Slate 7 network (should show 192.168.8.x).
**Reference:** https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig

---

### Ping Slate 7 gateway
```powershell
ping 192.168.8.1
```
**What it does:** Tests connectivity to the Slate 7 admin panel IP. Should reply when connected to Slate 7 Wi-Fi or LAN.
**Reference:** https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/ping

---

### Ping pfSense WAN IP (after DMZ config)
```powershell
ping 192.168.8.2
```
**What it does:** Verifies pfSense WAN interface received the correct IP from Slate 7 DMZ.

---

## Slate 7 Admin Panel — Browser Steps

All Slate 7 configuration is done through the web interface at `http://192.168.8.1`

### Access admin panel
```
http://192.168.8.1
```
**Reference:** https://docs.gl-inet.com/router/en/4/interface_guide/internet/

---

### Enable DMZ
```
More Settings → Network → DMZ
Enable: ON
DMZ Host IP: 192.168.8.2
```
**What it does:** Forwards all inbound traffic from the ISP to pfSense at 192.168.8.2. Eliminates double-NAT so pfSense sees real source IPs.
**Reference:** https://docs.gl-inet.com/router/en/4/interface_guide/firewall/#dmz

---

### Disable GL.iNet Cloud
```
More Settings → Cloud → Disable
```
**Reference:** https://docs.gl-inet.com/router/en/4/interface_guide/cloud/

---

### Disable SSH
```
More Settings → Administration → SSH → Disable
```
**Reference:** https://docs.gl-inet.com/router/en/4/interface_guide/ssh/

---

## Key References

| Topic | URL |
|-------|-----|
| GL.iNet documentation | https://docs.gl-inet.com/router/en/4/ |
| DMZ configuration | https://docs.gl-inet.com/router/en/4/interface_guide/firewall/#dmz |
| Network settings | https://docs.gl-inet.com/router/en/4/interface_guide/internet/ |
| GL.iNet Slate 7 product page | https://www.gl-inet.com/products/gl-axt1800/ |
