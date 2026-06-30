# Commands — 07 Wazuh SIEM Setup

---

## Container Setup

### Fix DNS in container
```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```
**Reference:** https://wiki.ubuntu.com/DNS

---

### Update and install dependencies
```bash
apt update && apt upgrade -y
apt install -y curl wget
```

---

## Wazuh Installation

### Download installer and config
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
```
**Reference:** https://documentation.wazuh.com/current/installation-guide/

---

### config.yml used
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

---

### Run installer (single node)
```bash
bash wazuh-install.sh -a
```
**What it does:** Installs Wazuh indexer (OpenSearch), Wazuh manager, and Wazuh dashboard in a single-node configuration. Takes 10-15 minutes.
**Reference:** https://documentation.wazuh.com/current/installation-guide/wazuh-server/step-by-step.html

---

## Custom Detection Rules

### Create custom rules file
```bash
nano /var/ossec/etc/rules/lab-custom-rules.xml
```
**Reference:** https://documentation.wazuh.com/current/user-manual/ruleset/custom.html

---

### Custom rules content (MITRE ATT&CK mapped)
```xml
<group name="lab,active_directory,">

  <!-- T1558.003 — Kerberoasting -->
  <rule id="100001" level="12">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4769$</field>
    <field name="win.eventdata.ticketEncryptionType">^0x17$</field>
    <description>Kerberoasting: RC4 TGS requested</description>
    <mitre><id>T1558.003</id></mitre>
  </rule>

  <!-- T1003.006 — DCSync -->
  <rule id="100002" level="10">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4662$</field>
    <field name="win.eventdata.properties" type="pcre2">(?i)(1131f6aa|1131f6ab|1131f6ac)</field>
    <description>AD enumeration: DCSync detected</description>
    <mitre><id>T1003.006</id></mitre>
  </rule>

  <!-- T1550.002 — Pass-the-Hash -->
  <rule id="100003" level="12">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4624$</field>
    <field name="win.eventdata.logonType">^3$</field>
    <field name="win.eventdata.authenticationPackageName">^NTLM$</field>
    <description>Possible Pass-the-Hash NTLM logon</description>
    <mitre><id>T1550.002</id></mitre>
  </rule>

  <!-- T1110 — Brute force -->
  <rule id="100004" level="10" frequency="5" timeframe="120">
    <if_matched_sid>60122</if_matched_sid>
    <description>Brute force: 5+ failed logons in 2 min</description>
    <mitre><id>T1110</id></mitre>
  </rule>

  <!-- T1046 — Port scan -->
  <rule id="100005" level="8">
    <if_sid>4700</if_sid>
    <match>SYN</match>
    <description>Port scan detected from $(srcip)</description>
    <mitre><id>T1046</id></mitre>
  </rule>

  <!-- T1003.001 — LSASS dump -->
  <rule id="100006" level="15">
    <if_sid>60103</if_sid>
    <field name="win.system.eventID">^4656$</field>
    <field name="win.eventdata.objectName" type="pcre2">(?i)lsass</field>
    <description>LSASS memory access — possible Mimikatz</description>
    <mitre><id>T1003.001</id></mitre>
  </rule>

</group>
```

---

### Restart Wazuh manager after rule changes
```bash
systemctl restart wazuh-manager
```

---

### Test rules loaded correctly
```bash
/var/ossec/bin/wazuh-logtest
```
**What it does:** Opens interactive log testing. Type Ctrl+C to exit.
**Reference:** https://documentation.wazuh.com/current/user-manual/ruleset/testing.html

---

### Check Wazuh manager status
```bash
systemctl status wazuh-manager
```

---

### Check all Wazuh services
```bash
systemctl status wazuh-indexer
systemctl status wazuh-manager
systemctl status wazuh-dashboard
```

---

## pfSense Syslog to Wazuh

### Configure in pfSense web GUI
```
Status → System Logs → Settings
Enable Remote Logging: ✓
Remote log server: 192.168.30.20
Port: 514
Protocol: UDP
Log: Firewall Events, DHCP, System, Authentication
```
**Reference:** https://docs.netgate.com/pfsense/en/latest/monitoring/logs/remote.html

---

## ARP Fix — Proxmox Gateway

### Add permanent ARP entry (run on Proxmox after USB adapter swap)
```bash
ip neigh replace 192.168.30.1 lladdr 00:0e:c6:47:3b:22 dev vmbr0 nud permanent
```
**What it does:** Permanently maps pfSense LAB gateway IP to its MAC address so Proxmox doesn't lose the gateway after reboots or ARP cache expiry.

### Verify ARP entry
```bash
ip neigh show | grep 192.168.30.1
```

---

## Key References

| Topic | URL |
|-------|-----|
| Wazuh documentation | https://documentation.wazuh.com/current/ |
| Wazuh install guide | https://documentation.wazuh.com/current/installation-guide/ |
| Custom rules | https://documentation.wazuh.com/current/user-manual/ruleset/custom.html |
| MITRE ATT&CK | https://attack.mitre.org/ |
| Wazuh agent deployment | https://documentation.wazuh.com/current/installation-guide/wazuh-agent/ |
| pfSense remote syslog | https://docs.netgate.com/pfsense/en/latest/monitoring/logs/remote.html |
