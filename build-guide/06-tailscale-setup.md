# Step 6 — Tailscale VPN Setup

## What you need
- pfSense running (Step 2 complete)
- Proxmox running (Step 4 complete)
- Free Tailscale account

---

## 6.1 — Create Tailscale account

Go to https://tailscale.com → Sign up (free — up to 100 devices).

Use your personal email or Google/GitHub login. Note your tailnet name — it looks like:
```
yourname.tailnet-xyz.ts.net
```

---

## 6.2 — Install Tailscale on pfSense

In pfSense web UI:

1. System → Package Manager → Available Packages
2. Search: `tailscale`
3. Click Install → Confirm

After install:

4. Go to VPN → Tailscale
5. Click **Authentication** tab
6. Click **Authenticate** — a URL appears
7. Copy the URL and open it in your browser
8. Log in with your Tailscale account → Authorize pfSense

Back in pfSense VPN → Tailscale → Settings:

```
Enable Tailscale:              ✓ checked
Advertised routes:             192.168.10.0/24
Accept DNS:                    ✗ unchecked  (Pi-hole handles DNS)
```

Save and Apply.

---

## 6.3 — Approve subnet route in Tailscale admin

Go to https://login.tailscale.com/admin/machines

Find pfSense in the list → click `...` → Edit route settings:

```
192.168.10.0/24:   ✓ Approved
```

Save.

---

## 6.4 — Install Tailscale on Proxmox

In Proxmox shell (node → Shell):

```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Start and authenticate — this prints a URL
tailscale up \
  --advertise-routes=192.168.30.0/24 \
  --ssh \
  --accept-dns=false
```

Copy the printed URL → open in browser → log in → authorize Proxmox.

Enable auto-start:
```bash
systemctl enable tailscaled
```

---

## 6.5 — Approve Proxmox subnet route

Go to https://login.tailscale.com/admin/machines

Find Proxmox in the list → click `...` → Edit route settings:

```
192.168.30.0/24:   ✓ Approved
```

Save.

---

## 6.6 — Set Tailscale ACL policy

Go to https://login.tailscale.com/admin/acls

Replace the default policy with:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["autogroup:member"],
      "dst": [
        "192.168.10.0/24:*",
        "192.168.30.0/24:*"
      ]
    }
  ],
  "ssh": [
    {
      "action": "accept",
      "src": ["autogroup:member"],
      "dst": ["autogroup:self"],
      "users": ["autogroup:nonroot", "root"]
    }
  ]
}
```

Click Save.

---

## 6.7 — Install Tailscale on your laptop and phone

**Mac:**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up
```

Or download the app from https://tailscale.com/download

**iPhone/Android:**
Install Tailscale from App Store or Google Play → sign in with same account.

---

## 6.8 — Verify remote access

Turn off your laptop's Wi-Fi and use mobile hotspot (or test from a different network). Enable Tailscale on your phone:

```bash
# Ping Proxmox over Tailscale
ping 192.168.30.10

# Ping Pi-hole over Tailscale
ping 192.168.10.2
```

Both should respond.

Open your phone browser:
```
https://192.168.30.10:8006     ← Proxmox (accept cert warning)
http://192.168.10.2/admin      ← Pi-hole dashboard
```

Both should load — from anywhere in the world — without any open ports.

---

## 6.9 — SSH to Proxmox via Tailscale (optional)

From your laptop anywhere:
```bash
ssh root@192.168.30.10
# Or using Tailscale hostname:
ssh root@proxmox.tailnet-xyz.ts.net
```

---

## 6.10 — Screenshots for GitHub

Take screenshots of:
- Tailscale admin panel showing pfSense and Proxmox connected
- Subnet routes approved for both nodes
- Your phone/laptop connected to Proxmox web UI over Tailscale

Save to:
```
homelab-portfolio/06-tailscale-vpn/screenshots/
```

---

## Done — move to Step 7
