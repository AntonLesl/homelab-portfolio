# Active Directory Lab Setup

## Domain
- Domain name: `lab.local`
- NetBIOS: `LAB`
- Domain Controller: `dc01` (10.10.10.10)

## Install AD DS on Windows Server 2022
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
# Regular users
New-ADUser -Name "jsmith" -SamAccountName "jsmith" `
  -UserPrincipalName "jsmith@lab.local" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) `
  -Enabled $true

# Service account with SPN (Kerberoasting target)
New-ADUser -Name "svc-sql" -SamAccountName "svc-sql" `
  -Path "OU=Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "ServicePass1!" -AsPlainText -Force) `
  -Enabled $true

Set-ADUser -Identity "svc-sql" `
  -ServicePrincipalNames @{Add="MSSQLSvc/dc01.lab.local:1433"}
```

## Enable Audit Policies
```powershell
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable

# PowerShell script block logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
```
