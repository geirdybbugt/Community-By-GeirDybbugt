####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
#### Downloads TeamViewer QS, adds to users desktop as shortcut
#### modified:: 5/5/2021
####------------------------------------------------------------------------####
<#
.SYNOPSIS
    Downloads TeamViewer QS, adds to users desktop as shortcut
    Intended to run via Intune.
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


# Download Teamviewer QS - add shortcut to users desktop

    # Get location to users desktop
        $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

    # Source and target for download of TeamViewer QS
        $Url = "https://download.teamviewer.com/download/TeamViewerQS.exe"
        $Target = "$env:SystemRoot\Temp\TeamViewerQS.exe"

    # Delete the target if it exists, so that we don't have issues
        If (Test-Path $Target) { Remove-Item -Path $Target -Force -ErrorAction SilentlyContinue }

    # Download TeamViewer QS locally
        Start-BitsTransfer -Source $Url -Destination $Target

    # Install Shortcut on desktop
        $SourceFileLocation = "$env:SystemRoot\Temp\TeamViewerQS.exe"
        $ShortcutLocation = "$DesktopPath\TeamViewer.lnk"

        $WScriptShell = New-Object -ComObject WScript.Shell

        $Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
        $Shortcut.TargetPath = $SourceFileLocation
        $Shortcut.Save()

# Clears the error log from powershell before exiting
    $error.clear()