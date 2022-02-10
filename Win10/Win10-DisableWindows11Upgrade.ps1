<# Script to disable upgrade to windows 11
edited: 09.12.21 - Geir Dybbugt - Dybbugt.no
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
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $TargetReleaseVersion = 1
    $ProductVersion = "Windows 10"
    $TargetReleaseVersionInfo = "21H2"

# Disable the windows 11 upgrade with registry settings
    if((Test-Path -LiteralPath $RegPath) -ne $true) {
      New-Item $RegPath -force
        if ($?) {
            New-ItemProperty -LiteralPath "$RegPath" -Name 'TargetReleaseVersion' -Value $TargetReleaseVersion -PropertyType DWORD -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath" -Name 'ProductVersion' -Value $ProductVersion -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath "$RegPath" -Name 'TargetReleaseVersionInfo' -Value $TargetReleaseVersionInfo -PropertyType String -Force -ea SilentlyContinue; 
        } else {
            write-host "failed" -ForegroundColor Red            
            }
    } else { 
        New-ItemProperty -LiteralPath "$RegPath" -Name 'TargetReleaseVersion' -Value $TargetReleaseVersion -PropertyType DWORD -Force -ea SilentlyContinue;
        New-ItemProperty -LiteralPath "$RegPath" -Name 'ProductVersion' -Value $ProductVersion -PropertyType String -Force -ea SilentlyContinue;
        New-ItemProperty -LiteralPath "$RegPath" -Name 'TargetReleaseVersionInfo' -Value $TargetReleaseVersionInfo -PropertyType String -Force -ea SilentlyContinue; 
    }

# Clears the error log from powershell before exiting
    $error.clear()