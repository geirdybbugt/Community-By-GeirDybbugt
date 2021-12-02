####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
#### Removes windows store receiver before installing latest native receiver
#### modified:: 11/11/2021
####------------------------------------------------------------------------####
<#
.SYNOPSIS
    Removes windows store receiver, then downloads and installs native Citrix Receiver.
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

# Stop Workspace klient
    $processes = "*Receiver*", "*SelfService*", "*CtxWebBrowser*", "*SelfServicePlugin*", "*wfcrun32*", "*wfica32*","*wfcrun*","*wfica*", "*concentr*", "*authmansvr*"

    Foreach ($process in $processes)
    {
        Write-host "Checking process:" $process
        if ((get-process "$process" -ea SilentlyContinue) -eq $Null)
        {
            echo "Not Running"
        }
        else
        {
            echo "Running"
            Stop-Process -processname "$process" -Force
        }
    }

# Remove Windows store app
    $apps = "*Citrixreceiver*"

    Foreach ($app in $apps)
    {
      Write-host "Uninstalling:" $app
      Get-AppxPackage -allusers $app | Remove-AppxPackage
      Get-AppxPackage $app | Remove-AppxPackage

    }

        # Cirix Receiver download source
        $Url = "https://downloadplugins.citrix.com/Windows/CitrixWorkspaceApp.exe"
        $Target = "$env:SystemRoot\Temp\CitrixWorkspaceAppWeb.exe"

        # Delete the target if it exists, so that we don't have issues
        If (Test-Path $Target) { Remove-Item -Path $Target -Force -ErrorAction SilentlyContinue }

        # Download Citrix Receiver locally
        Start-BitsTransfer -Source $Url -Destination $Target

        # Install Citrix Receiver
        If (Test-Path $Target) { Start-Process -FilePath $Target -ArgumentList "/AutoUpdateCheck=auto /Allowaddstore=N /AutoUpdateStream=Current /DeferUpdateCount=5 /AURolloutPriority=Medium /NoReboot /Silent EnableCEIP=False"}

# Clears the error log from powershell before exiting
    $error.clear()