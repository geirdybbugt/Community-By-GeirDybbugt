<# 
Script to Set specific screen saver on non enterprise editions of windows 10/11 via intune 
as this is not supported via native intune policies. 
script will set screen saver to the "blank" screen saver, with requirement for password to unlock.

PS: remove the sections for the part you are not going to use, and deploy the script using user credentials or system in intune, depending on what section you are going to use
 
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

# Generic Variables
    $ScreenSaverTimeout = "900"
    $ScreenSaverName ="scrnsave.scr"

# Section to set values for current user with admin rights

    # Specific Variables for the section
        $RegPath = "HKCU:\Software\Policies\Microsoft\Windows\control panel\desktop" # Change to HKLM to set for the device

    # Set the config
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

# Section to set values for current user with standard rights

    # Specific Variables for the section
        $RegPath2 = "HKCU:\Control Panel\Desktop" 

    # Set the config
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

# Section to set values via HKU as System user - to last logged on user on device

    # Specific Variables for the section
        $RegPath3 = "Software\Policies\Microsoft\Windows\control panel\desktop"

    # Get info about the last logged on user
        $GetLastLoggedOnUser = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
        $LastLoggedOnUserSID = Get-ItemProperty -Path $GetLastLoggedOnUser
        $LastLoggedOnUserSID = $LastLoggedOnUserSID.LastLoggedOnUserSID
        
        # Create HKU path for the system process to use 
            $HKUpath = "HKU:\$LastLoggedOnUserSID\$Regpath3" # Path for the last logged on user on the device
            $HKUpath
            $HKUpath2 = "HKU:\.DEFAULT\$Regpath3" # Path for the .Default user profile - for all new user profiles

    # Map HKU in registry as available drive in OS
        New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

        # Liste available PS drives
            #Get-PSDrive

    # Set the config

        # Values for Last logged on user
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

        # Values for the  .Default profile
            if((Test-Path -LiteralPath $HKUpath2) -ne $true) {
                New-Item $HKUpath2 -force
                    if ($?) {
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
                    } else {
                        write-host "failed" -ForegroundColor Red
                        }
                } else { 
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'ScreenSaveActive' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'ScreenSaverIsSecure' -Value '1' -PropertyType String -Force -ea SilentlyContinue; 
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'SCRNSAVE.EXE' -Value $ScreenSaverName -PropertyType String -Force -ea SilentlyContinue;
                        New-ItemProperty -LiteralPath "$HKUpath2" -Name 'ScreenSaveTimeOut' -Value $ScreenSaverTimeout -PropertyType String -Force -ea SilentlyContinue;
                }

    # Unmap HKU from available PS drives before exiting
            Remove-PSDrive hku

# Clears the error log from powershell before exiting
    $error.clear()