# Step 1 — GL.iNet Slate 7 WAN Setup

## What you need
- GL.iNet Slate 7 router
- Ethernet cable from ISP modem
- Ethernet cable to pfSense WAN NIC
- Laptop to access admin panel

---

## 1.1 — Physical connections

```
ISP Modem (LAN port)
        │
        └── Ethernet cable ──► Slate 7 WAN port
                                      │
                           Slate 7 LAN port ──► pfSense WAN NIC
```

Plug in and power on the Slate 7. Wait 60 seconds for it to boot.

---

## 1.2 — Access admin panel

Connect your laptop to the Slate 7 via Wi-Fi or ethernet LAN port.

Open browser and go to:
```
http://192.168.8.1
```

Set a strong admin password when prompted. Write it down.

---

## 1.3 — Verify WAN connection

In the Slate 7 admin panel:
```
Internet → Cable
```

You should see a public IP address assigned from your ISP. If you see `0.0.0.0` wait another 30 seconds and refresh. Note this IP — you will verify pfSense receives it later.

---

## 1.4 — Enable DMZ mode

Go to:
```
More Settings → Network → DMZ
```

Settings:
```
Enable DMZ:   ON
DMZ Host IP:  192.168.8.2   ← this is pfSense WAN IP
```

Click Save and Apply.

**Why DMZ?** Without DMZ, pfSense sits behind double-NAT and cannot see real source IPs. Suricata and firewall rules need true IP visibility to work correctly.

---

## 1.5 — Harden the Slate 7

```
More Settings → Administration
  → SSH:    Disable
  → Remote Access: Disable

More Settings → Cloud
  → GL.iNet Cloud: Disable

Wireless
  → 2.4GHz: Disable (if not needed)
  → 5GHz:   Disable (if not needed)
```

---

## 1.6 — Verify checklist

| Check | Expected | How to verify |
|-------|---------|---------------|
| Slate 7 WAN IP | Public ISP IP | Internet → Cable |
| Slate 7 LAN | 192.168.8.1 | Admin panel URL |
| DMZ enabled | ON pointing to 192.168.8.2 | More Settings → DMZ |

---

## 1.7 — Screenshot for GitHub

Take a screenshot of:
- The DMZ settings page showing it enabled and pointing to 192.168.8.2
- The Internet status page showing your WAN IP

Save as:
```
homelab-portfolio/01-slate7-wan-setup/screenshots/dmz-config.png
homelab-portfolio/01-slate7-wan-setup/screenshots/wan-status.png
```

---

## Done — move to Step 2
