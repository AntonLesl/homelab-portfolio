@echo off
setlocal EnableExtensions

:: =============================================================================
:: Script Name : CreateLocalAdmin_LeaveDomain.cmd
:: Author      : Anton Leslie
:: Purpose     : Creates a local administrator account, verifies it,
::               removes the computer from the AMW.local domain,
::               joins the WORKGROUP workgroup, and restarts the computer.
::
:: Requirements:
::   - Must be run as Administrator.
::   - User running the script must have permission to remove the computer
::     from the domain.
::   - PowerShell must be available (Windows 10/11 or Windows Server).
::
:: Local Account:
::   Username : tie
::   Password : Password1
::
:: WARNING:
::   After the computer leaves the domain, domain user accounts will no longer
::   authenticate unless cached credentials are available. Verify the local
::   administrator account works before removing the system from the domain.
:: =============================================================================

title Create Local Administrator and Leave Domain

echo.
echo ============================================================
echo   Create Local Administrator and Remove from Domain
echo ============================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Administrative privileges are required.
    echo.
    echo Right-click this file and select:
    echo     Run as administrator
    echo.
    pause
    exit /b 1
)

echo [1/4] Creating local user account...
net user tie Password1 /add

echo.
echo [2/4] Adding account to the local Administrators group...
net localgroup Administrators tie /add

echo.
echo [3/4] Verifying local account...
net user tie

echo.
echo ============================================================
echo Local administrator account is ready.
echo.
echo Username : tie
echo Password : Password1
echo ============================================================
echo.

echo [4/4] Removing computer from AMW.local...
echo.

powershell -NoProfile -ExecutionPolicy Bypass ^
"Remove-Computer -WorkgroupName 'WORKGROUP' -UnjoinDomainCredential (Get-Credential) -Force -Restart"

echo.
echo If the operation succeeds, the computer will restart automatically.
echo If prompted, provide domain administrator credentials.
echo.

pause

endlocal
