<# 
Script to Set specific screen saver on non enterprise editions of windows 10/11 via intune 
as this is not supported via native intune policies. 
script will set screen saver to the "blank" screen saver, with requirement for password to unlock. 
edited: 13:07 10.02.2022 - Geir Dybbugt - Dybbugt.no
#>

# Restart Process using PowerShell 64-bit 
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}

# Variables
    $ScreenSaverTimeout = "900"
    $ScreenSaverName ="scrnsave.scr"

    $RegPath = "HKCU:\Software\Policies\Microsoft\Windows\control panel\desktop" # Change to HKLM to set for the device
    $RegPath2 = "HKCU:\Control Panel\Desktop" 
    $RegPath3 = "Software\Policies\Microsoft\Windows\control panel\desktop"

    $GetLastLoggedOnUser = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
    $LastLoggedOnUserSID = Get-ItemProperty -Path $GetLastLoggedOnUser
    $LastLoggedOnUserSID = $LastLoggedOnUserSID.LastLoggedOnUserSID


# Set values for current user with admin rights
if((Test-Path -LiteralPath $RegPath) -ne $true) {
    New-Item $RegPath -force
        if ($?) {
            New-ItemProperty -LiteralPath "$RegPath" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
            New-ItemProperty -LiteralPath "$RegPath" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
        } else {
            write-host "failed" -ForegroundColor Red
            }
    } else { 
            New-ItemProperty -LiteralPath "$RegPath" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
            New-ItemProperty -LiteralPath "$RegPath" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
    }

# Set values for current user with standard rights
if((Test-Path -LiteralPath $RegPat2h) -ne $true) {
    New-Item $RegPath2 -force
        if ($?) {
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
        } else {
            write-host "failed" -ForegroundColor Red
            }
    } else { 
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath2" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
    }

# Set values via HKU as System user - to last logged on user on device
    # Variables
        $HKUpath = "HKU:\$LastLoggedOnUserSID\$Regpath3"
        $HKUpath

    # Map HKU in registry as available drive in OS
        New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

        # Liste available PS drives
            #Get-PSDrive

if((Test-Path -LiteralPath $HKUpath) -ne $true) {
    New-Item $HKUpath -force
        if ($?) {
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
        } else {
            write-host "failed" -ForegroundColor Red
            }
    } else { 
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$HKUpath" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
    }

    # Unmap HKU from available PS drives before exiting
            Remove-PSDrive hku

# Clears the error log from powershell before exiting
    $error.clear()