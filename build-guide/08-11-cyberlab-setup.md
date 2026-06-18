# Steps 8–11 — Cyber Lab VMs

## Overview — build order matters
```
Step 8: Windows Server 2022 (DC)     ← build first — Win10 needs domain to join
Step 9: Windows 10 (victim)          ← build second — joins domain from Step 8
Step 10: Kali Linux (attacker)       ← build third — needs confirmed targets
Step 11: Metasploitable 2 (target)   ← anytime after Proxmox + vmbr2 exist
```

---

# Step 8 — Windows Server 2022 (Domain Controller)

## 8.1 — Download Windows Server 2022

Go to: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022

Download the ISO (180-day free evaluation). Upload to Proxmox:

In Proxmox web UI → local storage → ISO Images → Upload

Or from Proxmox shell:
```bash
# Upload via wget if you have a direct link
wget -O /var/lib/vz/template/iso/WinServer2022.iso "YOUR_DOWNLOAD_URL"
```

Also download VirtIO drivers ISO (needed for Windows to see the disk and NIC):
```bash
wget -O /var/lib/vz/template/iso/virtio-win.iso \
  https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
```

---

## 8.2 — Create Windows Server VM

Proxmox web UI → Create VM:

```
General:
  VM ID:    201
  Name:     dc01

OS:
  ISO:      WinServer2022.iso
  Type:     Microsoft Windows
  Version:  11/2022/2025

System:
  BIOS:     OVMF (UEFI)
  Machine:  q35
  TPM:      ✓ Add TPM (v2.0)

Disks:
  Bus:      VirtIO SCSI
  Size:     60 GB
  Storage:  local-lvm

CPU:
  Sockets:  1
  Cores:    2
  Type:     host

Memory:
  4096 MB

Network:
  Bridge:   vmbr2        ← isolated lab network
  Model:    VirtIO
  (No VLAN tag — vmbr2 is internal only)
```

Before clicking Finish — add second CD drive for VirtIO:
- Hardware → Add → CD/DVD Drive
- Select virtio-win.iso

Click Finish → Start VM.

---

## 8.3 — Install Windows Server 2022

Open console (VM 201 → Console):

1. Windows installer loads → select **Windows Server 2022 Standard (Desktop Experience)**
2. Custom install → select VirtIO disk (you may need to load driver first):
   - Click "Load driver"
   - Browse to CD drive (virtio-win) → `viostor\2k22\amd64`
   - Select and install the VirtIO SCSI driver
   - Disk appears → select it → install Windows
3. Set Administrator password during setup

---

## 8.4 — Install VirtIO network driver

After Windows boots, open File Explorer → navigate to the virtio CD drive:
```
vioserial\2k22\amd64    → install
NetKVM\2k22\amd64       → install (this gives you the NIC)
```

Or run the VirtIO installer: `virtio-win-gt-x64.msi` on the CD root.

---

## 8.5 — Set static IP

Control Panel → Network and Sharing Center → Change adapter settings → Ethernet → Properties → IPv4:

```
IP:       10.10.10.10
Mask:     255.255.255.0
Gateway:  (leave blank — no internet)
DNS 1:    127.0.0.1    ← DC will be its own DNS server
DNS 2:    (blank)
```

Click OK.

---

## 8.6 — Promote to Domain Controller

Open PowerShell as Administrator:

```powershell
# Install AD Domain Services role
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Promote to DC — creates new forest lab.local
Install-ADDSForest `
  -DomainName "lab.local" `
  -DomainNetbiosName "LAB" `
  -InstallDns `
  -SafeModeAdministratorPassword (ConvertTo-SecureString "Lab@Password123!" -AsPlainText -Force) `
  -Force
```

Server reboots. Login as `LAB\Administrator`.

---

## 8.7 — Create domain users

Open PowerShell as Administrator:

```powershell
# Create OUs
New-ADOrganizationalUnit -Name "Users" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "Workstations" -Path "DC=lab,DC=local"

# Create regular user — Kerberoasting source account
New-ADUser `
  -Name "John Smith" `
  -SamAccountName "jsmith" `
  -UserPrincipalName "jsmith@lab.local" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) `
  -Enabled $true

# Create second user
New-ADUser `
  -Name "Tom Jones" `
  -SamAccountName "tjones" `
  -UserPrincipalName "tjones@lab.local" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "Password456!" -AsPlainText -Force) `
  -Enabled $true

# Create service account with SPN (Kerberoasting TARGET)
New-ADUser `
  -Name "svc-sql" `
  -SamAccountName "svc-sql" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "ServicePass1!" -AsPlainText -Force) `
  -Enabled $true

# Add SPN to service account — this is what makes it Kerberoastable
Set-ADUser -Identity "svc-sql" `
  -ServicePrincipalNames @{Add="MSSQLSvc/dc01.lab.local:1433"}

# Verify SPN was added
Get-ADUser -Identity "svc-sql" -Properties ServicePrincipalName | Select ServicePrincipalName
```

---

## 8.8 — Enable audit policies

```powershell
# These events feed Wazuh detection rules
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Directory Service Access" /success:enable /failure:enable
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable

# Enable PowerShell script block logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f

# Verify audit policy
auditpol /get /category:*
```

---

## 8.9 — Install Wazuh agent on Windows Server

In Wazuh dashboard → Agents → Deploy new agent:

```
OS:           Windows
Manager IP:   192.168.30.20
Agent name:   dc01
```

Copy the PowerShell command shown. Run it in PowerShell as Administrator on dc01:

```powershell
# Example (use exact command from Wazuh dashboard — it includes your manager IP)
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi -OutFile wazuh-agent.msi
.\wazuh-agent.msi /q WAZUH_MANAGER="192.168.30.20" WAZUH_AGENT_NAME="dc01"
NET START WazuhSvc
```

Verify in Wazuh dashboard → Agents → dc01 should show as Active.

---

## 8.10 — Snapshot DC

```bash
# In Proxmox shell
qm snapshot 201 clean-state --description "Clean DC — before any lab exercises"
```

---

# Step 9 — Windows 10 (Victim Workstation)

## 9.1 — Download Windows 10 ISO

Download from: https://www.microsoft.com/en-us/software-download/windows10ISO

Upload to Proxmox local storage → ISO Images.

---

## 9.2 — Create Windows 10 VM

```
VM ID:    202
Name:     win10
OS ISO:   Windows10.iso
System:   OVMF, q35
Disk:     60 GB, VirtIO SCSI
CPU:      2 cores
RAM:      4096 MB
Network:  vmbr2, VirtIO  ← isolated lab only
```

Add second CD drive with virtio-win.iso. Finish → Start.

---

## 9.3 — Install Windows 10

During install select **Windows 10 Pro** (needed for domain join).

Install VirtIO drivers same as Step 8.4.

---

## 9.4 — Set static IP

```
IP:       10.10.10.20
Mask:     255.255.255.0
Gateway:  (blank)
DNS 1:    10.10.10.10    ← points to DC for domain resolution
DNS 2:    (blank)
```

---

## 9.5 — Join domain

```
Settings → System → About → Domain or workgroup → Join a domain
Domain: lab.local
```

Enter credentials: `LAB\Administrator` + Administrator password.

Reboot when prompted.

Login as `LAB\jsmith` (password: `Password123!`).

---

## 9.6 — Install Wazuh agent

Same process as Step 8.9 but set agent name to `win10`:

```powershell
.\wazuh-agent.msi /q WAZUH_MANAGER="192.168.30.20" WAZUH_AGENT_NAME="win10"
NET START WazuhSvc
```

Verify in Wazuh dashboard → both dc01 and win10 now show Active.

---

## 9.7 — Snapshot

```bash
qm snapshot 202 clean-state --description "Clean Win10 — domain joined, before lab"
```

---

# Step 10 — Kali Linux (Attacker)

## 10.1 — Download Kali Linux ISO

```
https://www.kali.org/get-kali/#kali-installer-images
```

Download the installer (not live) AMD64 version. Upload to Proxmox.

---

## 10.2 — Create Kali VM

```
VM ID:    200
Name:     kali-attacker
OS:       kali-linux-*.iso, Linux, Debian 11
System:   OVMF (UEFI)
Disk:     80 GB, VirtIO SCSI
CPU:      2 cores
RAM:      4096 MB
Network:  vmbr2, VirtIO   ← isolated lab only
```

Finish → Start.

---

## 10.3 — Install Kali Linux

Boot from ISO → Graphical Install:

```
Hostname:     kali
Domain:       (blank)
Username:     kali
Password:     (set strong password)
Disk:         Guided — use entire disk
```

Complete install → reboot.

---

## 10.4 — Set static IP

```bash
# Open terminal
sudo nano /etc/network/interfaces
```

Add:
```
auto eth0
iface eth0 inet static
  address 10.10.10.5
  netmask 255.255.255.0
```

```bash
sudo systemctl restart networking
ip addr show eth0
# Should show 10.10.10.5
```

---

## 10.5 — Add /etc/hosts entries

```bash
sudo nano /etc/hosts
```

Add:
```
10.10.10.5    kali
10.10.10.10   dc01 dc01.lab.local
10.10.10.20   win10 win10.lab.local
10.10.10.30   metasploitable
```

---

## 10.6 — Update Kali and install tools

```bash
sudo apt update && sudo apt upgrade -y

# Install additional tools not in default Kali
sudo apt install -y \
  bloodhound \
  neo4j \
  impacket-scripts \
  crackmapexec \
  evil-winrm \
  python3-impacket
```

---

## 10.7 — Test lab connectivity

```bash
# These SHOULD work (all on vmbr2)
ping -c 3 10.10.10.10      # DC
ping -c 3 10.10.10.20      # Win10

# These SHOULD FAIL (isolation working)
ping -c 3 192.168.10.1     # pfSense — should timeout
ping -c 3 192.168.30.20    # Wazuh — should timeout
ping -c 3 8.8.8.8          # internet — should timeout
```

If the isolation pings succeed (they should fail), recheck vmbr2 config in /etc/network/interfaces on Proxmox.

---

## 10.8 — Install Wazuh agent on Kali

```bash
# Add Wazuh repo
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" \
  | sudo tee /etc/apt/sources.list.d/wazuh.list

sudo apt update

# Install agent pointing to Wazuh manager
sudo WAZUH_MANAGER='192.168.30.20' WAZUH_AGENT_NAME='kali-attacker' \
  apt install -y wazuh-agent

sudo systemctl enable --now wazuh-agent

# Verify connection
sudo /var/ossec/bin/agent_control -l
# Should show: kali-attacker  Active
```

---

## 10.9 — Snapshot Kali

```bash
qm snapshot 200 clean-state --description "Clean Kali — before any attack exercises"
```

---

# Step 11 — Metasploitable 2 (Vulnerable Target)

## 11.1 — Download Metasploitable 2

Go to: https://sourceforge.net/projects/metasploitable/files/Metasploitable2/

Download the `.zip` file. Unzip — you will get a `.vmdk` file.

---

## 11.2 — Upload VMDK to Proxmox

```bash
# From your Mac terminal
scp Metasploitable2.vmdk root@192.168.30.10:/var/lib/vz/template/iso/
```

---

## 11.3 — Import into Proxmox

In Proxmox shell:

```bash
# Create VM shell
qm create 203 \
  --name metasploitable \
  --memory 512 \
  --cores 1 \
  --net0 virtio,bridge=vmbr2

# Import the VMDK as a disk
qm importdisk 203 /var/lib/vz/template/iso/Metasploitable2.vmdk local-lvm

# Attach the disk
qm set 203 \
  --scsi0 local-lvm:vm-203-disk-0 \
  --boot c \
  --bootdisk scsi0 \
  --scsihw virtio-scsi-pci

# Start it
qm start 203
```

---

## 11.4 — Set static IP

Open console (VM 203 → Console).

Default login: `msfadmin` / `msfadmin`

```bash
sudo nano /etc/network/interfaces
```

Change eth0:
```
auto eth0
iface eth0 inet static
  address 10.10.10.30
  netmask 255.255.255.0
```

```bash
sudo /etc/init.d/networking restart
ip addr show eth0
# Should show 10.10.10.30
```

**Do NOT install Wazuh on Metasploitable** — leave it as a pure vulnerable target.

---

## 11.5 — Test from Kali

```bash
# From Kali terminal
ping -c 3 10.10.10.30
nmap -sV 10.10.10.30
```

You should see many open vulnerable services listed.

---

## 11.6 — Snapshot

```bash
qm snapshot 203 clean-state --description "Clean Metasploitable — before lab"
```

---

## Verify all agents in Wazuh

In Wazuh dashboard → Agents:

```
dc01            Active    ← Windows Server
win10           Active    ← Windows 10
kali-attacker   Active    ← Kali Linux
```

All three should show green Active status.

---

## Screenshots for GitHub

Take screenshots of:
- Wazuh dashboard showing all 3 agents Active
- Kali terminal showing successful ping to DC and Win10
- Kali terminal showing FAILED ping to pfSense (isolation proof)
- Proxmox showing all 4 VMs running

Save to:
```
homelab-portfolio/07-cyber-lab/screenshots/
```

---

## Done — move to Step 12 (Suricata)
