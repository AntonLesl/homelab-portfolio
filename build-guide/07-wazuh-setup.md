# Step 7 — Wazuh SIEM Setup

## What you need
- Proxmox running with vmbr0 working (Step 4)
- 8GB RAM and 50GB disk available on Proxmox
- pfSense syslog configured (Step 2.9)

---

## 7.1 — Create Wazuh LXC container

In Proxmox web UI → Create CT:

```
General:
  CT ID:        101
  Hostname:     wazuh
  Password:     (set strong password)

Template:
  ubuntu-22.04-standard

Disks:
  Size:         50 GB    ← logs grow fast, do not go smaller

CPU:
  Cores:        4

Memory:
  Memory:       8192 MB   ← Wazuh + Elasticsearch needs this
  Swap:         2048 MB

Network:
  Bridge:       vmbr0
  VLAN Tag:     30
  IPv4:         Static
  IPv4/CIDR:    192.168.30.20/24
  Gateway:      192.168.30.1

DNS:
  DNS servers:  192.168.10.2
```

Finish → Start container.

---

## 7.2 — Update container

Open console (click container 101 → Console):

```bash
apt update && apt upgrade -y
apt install -y curl wget gnupg
```

---

## 7.3 — Install Wazuh (single-node)

```bash
# Download installer
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
```

Edit the config file:
```bash
nano config.yml
```

Replace all content with:
```yaml
nodes:
  indexer:
    - name: node-1
      ip: "192.168.30.20"
  server:
    - name: wazuh-1
      ip: "192.168.30.20"
  dashboard:
    - name: dashboard
      ip: "192.168.30.20"
```

Save: `Ctrl+X` → `Y` → Enter

Run installer (takes 10–15 minutes):
```bash
bash wazuh-install.sh -a
```

**IMPORTANT:** At the end of install, the script prints credentials:
```
INFO: --- Summary ---
INFO: You can access the web interface https://192.168.30.20
    User: admin
    Password: XXXXXXXXXXXXXXXXXX
```

**Save that password somewhere safe.** You cannot recover it easily.

---

## 7.4 — Access Wazuh dashboard

From your laptop:
```
https://192.168.30.20
```

Accept the certificate warning.

Login:
```
Username: admin
Password: (printed by installer)
```

You should see the Wazuh dashboard. No agents connected yet — that is fine.

---

## 7.5 — Configure pfSense syslog to Wazuh

In pfSense web UI → Status → System Logs → Settings:

```
Enable Remote Logging:   ✓ checked
Remote log server 1:     192.168.30.20
Remote Syslog Port:      514
Protocol:                UDP

Log Contents:
  ✓ Firewall Events
  ✓ DHCP Events
  ✓ System Events
  ✓ Authentication Events
```

Save.

Configure Wazuh to receive syslog from pfSense:

```bash
# In Wazuh console
nano /var/ossec/etc/ossec.conf
```

Find the `<ossec_config>` block and add inside it:
```xml
<remote>
  <connection>syslog</connection>
  <port>514</port>
  <protocol>udp</protocol>
  <allowed-ips>192.168.10.1</allowed-ips>
  <allowed-ips>192.168.30.1</allowed-ips>
</remote>
```

Save and restart Wazuh:
```bash
systemctl restart wazuh-manager
```

---

## 7.6 — Upload custom detection rules

```bash
# In Wazuh console
nano /var/ossec/etc/rules/lab-custom-rules.xml
```

Paste the full rule file from:
```
homelab-portfolio/08-wazuh-siem/custom-rules.xml
```

(Copy and paste the content of that file here)

Save and restart:
```bash
/var/ossec/bin/wazuh-control restart
```

Verify rules loaded without errors:
```bash
/var/ossec/bin/wazuh-logtest
```

---

## 7.7 — Verify pfSense events arriving

Wait 2–3 minutes after pfSense syslog is configured, then in Wazuh dashboard:

Security Events → filter by:
```
agent.name: pfSense  (or check all recent events)
```

You should see pfSense firewall events appearing.

---

## 7.8 — Add static lease to pfSense

In pfSense → Services → DHCP Server → LAB → Static Mappings:

Get Wazuh MAC:
```bash
# In Wazuh console
ip link show eth0
```

Add in pfSense:
```
MAC:        (Wazuh MAC)
IP:         192.168.30.20
Hostname:   wazuh
```

---

## 7.9 — Screenshots for GitHub

Take screenshots of:
- Wazuh dashboard home showing connected agents (will be 0 now)
- Security Events showing pfSense firewall logs
- Rules page showing custom lab rules loaded

Save to:
```
homelab-portfolio/08-wazuh-siem/screenshots/
```

---

## Done — move to Step 8
