# Commands — 09 Cyber Lab (Active Directory)

## Promote Windows Server to a Domain Controller (PowerShell)

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "[lab.domain]" -InstallDns
```
**Why:** Stands up Active Directory Domain Services and creates the forest/domain that the victim workstation joins. `-InstallDns` sets up the DC as DNS for the domain.
**Where learned:** https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services

## Create AD users and OUs

```powershell
New-ADOrganizationalUnit -Name "Lab Users"
New-ADUser -Name "[user]" -AccountPassword (Read-Host -AsSecureString) -Enabled $true
```
**Why:** Populates the domain with users so attacks like Kerberoasting have something to target.
**Where learned:** https://learn.microsoft.com/powershell/module/activedirectory/

## Register an SPN for a service account (Kerberoasting target)

```powershell
setspn -A HTTP/[service host] [service account]
```
**Why:** A service account with an SPN is the prerequisite for a Kerberoasting exercise. This intentionally creates the target condition.
**Where learned:** https://learn.microsoft.com/windows-server/administration/windows-commands/setspn

## Join the Windows 10 victim to the domain (PowerShell)

```powershell
Add-Computer -DomainName "[lab.domain]" -Credential [domain admin] -Restart
```
**Why:** Makes the workstation a domain member so it behaves like a real enterprise endpoint.
**Where learned:** https://learn.microsoft.com/powershell/module/microsoft.powershell.management/add-computer

## Check network config on lab hosts (no DHCP on vmbr2)

```powershell
ipconfig /all
```
**Why:** vmbr2 has no DHCP server, so lab hosts use static IPs. This confirms addressing during setup. See ISSUES.md.
