<#
Script to disable screen autorotation and set desired orientation
update: 13:30 01.03.2023
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
# Disable automatic rotation
$AutoRotationPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AutoRotation"
Set-ItemProperty -Path $AutoRotationPath -Name Enable 0

# Change all connected monitor to desired orientation
$RotationValue = 1 # 1=Landscape 2=Portrait 3=Landscape (flipped) 4=Portrait (flipped)
$ScreenOrientationPath = "HKLMs:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration\*\00\00\"
$GetAutoRotationValuePath = Get-childitem -path $ScreenOrientationPath | Where-Object Property -EQ Rotation | Select-Object -ExpandProperty Name
$ValuePath = $GetAutoRotationValuePath -replace "HKEY_LOCAL_MACHINE", "HKLM:"
foreach ($value in $ValuePath) {
    Try {
        Set-ItemProperty -Path $Value -Name Rotation $RotationValue
        IF ($? -eq $true) {
            Write-host "Set registry value success!" -ForegroundColor Green
        } 
    }
    Catch {
        Write-host "Set registry value failed!" -ForegroundColor yellow
        Write-host "Message: [$($_.Exception.Message)"] -ForegroundColor Red -BackgroundColor
    }   
}

# Clears the error log from powershell before exiting
$error.clear()

# Exit
Exit 0
