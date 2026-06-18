# Active Directory Lab Setup

## Domain Info
- Domain: `lab.local` | NetBIOS: `LAB`
- DC IP: 10.10.10.10 | Admin: `LAB\Administrator`

## Promote to Domain Controller
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
  -DomainName "lab.local" `
  -DomainNetbiosName "LAB" `
  -InstallDns `
  -SafeModeAdministratorPassword (ConvertTo-SecureString "Lab@Password123!" -AsPlainText -Force) `
  -Force
```

## Create Lab Users
```powershell
New-ADOrganizationalUnit -Name "Users" -Path "DC=lab,DC=local"

New-ADUser -Name "jsmith" -SamAccountName "jsmith" `
  -UserPrincipalName "jsmith@lab.local" -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true

# Kerberoasting target — service account with SPN
New-ADUser -Name "svc-sql" -SamAccountName "svc-sql" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "ServicePass1!" -AsPlainText -Force) -Enabled $true

Set-ADUser -Identity "svc-sql" -ServicePrincipalNames @{Add="MSSQLSvc/dc01.lab.local:1433"}
```

## Enable Audit Policies
```powershell
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
```
