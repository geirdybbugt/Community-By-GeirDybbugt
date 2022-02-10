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
    $RegPath = "HKCU:\Software\Policies\Microsoft\Windows\control panel\desktop"
    $ScreenSaverName = "scrnsave.scr"
    $ScreenSaverTimeout = "900"

# Set values
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

# Clears the error log from powershell before exiting
    $error.clear()