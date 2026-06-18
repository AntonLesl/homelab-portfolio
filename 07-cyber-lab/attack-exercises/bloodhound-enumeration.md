# Attack Exercise — BloodHound AD Enumeration

**MITRE ATT&CK:** T1087.002  
**Tool:** BloodHound + bloodhound-python collector  
**Goal:** Map attack paths to Domain Admin

## Attack
```bash
# Collect AD data from Kali
bloodhound-python \
  -u jsmith \
  -p 'Password123!' \
  -d lab.local \
  -ns 10.10.10.10 \
  -c all \
  --zip

# Launch BloodHound UI and import zip
# Queries to run:
# - Shortest Paths to Domain Admins
# - Find Kerberoastable Users
# - Find AS-REP Roastable Users
# - Principals with DCSync Rights
```

## Detection (Wazuh)
- Event ID 4662 — LDAP read on AD objects (replication rights)
- High volume of LDAP queries from 10.10.10.5 in short window
- Wazuh rule 100002 fires at level 10

## Evidence
Add screenshot of BloodHound graph + Wazuh alert here
