####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
#### Removes windows store receiver before installing latest native receiver
#### modified:: 5/5/2021
####------------------------------------------------------------------------####
<#
.SYNOPSIS
    Removes windows store receiver, then downloads and installs native Citrix Receiver.
    Remember to Edit store url and names before deploying
    You can package the install and uninstall script as a win32 app with the IntuneWinAppUtil to deploy as a win32 app
    Details for detectin rules and install commands are in the included txt file
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
    if ((get-process "Receiver" -ea SilentlyContinue) -eq $Null)
    {
        echo "Not Running"
    }
    else
    {
        echo "Running"
        Stop-Process -processname "Receiver"
    }

    if ((get-process "SelfService" -ea SilentlyContinue) -eq $Null)
    {
        echo "Not Running"
    }
    else
    {
        echo "Running"
        Stop-Process -processname "SelfService"
    }

# Remove Windows store app
    $apps = "*Citrixreceiver*"

    Foreach ($app in $apps)
    {
      Write-host "Uninstalling:" $app
      Get-AppxPackage -allusers $app | Remove-AppxPackage
    }

# adds registry configuration for Citrix Store
    $RegKeyPath = 'HKLM:\SOFTWARE\Policies\Citrix\Receiver\Sites'
    $Store1 = "STORE1"
    $Store1Value = "Storename;https://login.something.com/Citrix/StoreName/discovery;On;Citrix" #<<<------ Change to your url and names
    IF(!(Test-Path $RegKeyPath))
    {
    New-Item -Path $RegKeyPath -Force | Out-Null
    }

    New-ItemProperty -Path $RegKeyPath -Name $Store1 -Value $Store1Value -PropertyType STRING -Force | Out-Null

# If Native Receiver is already installed, skip download and install
    If (!(Get-WmiObject -Class Win32_Product | Where-Object Name -Like "Citrix Workspace*")) {

        # Cirix Receiver download source
        $Url = "https://downloadplugins.citrix.com/Windows/CitrixWorkspaceApp.exe"
        $Target = "$env:SystemRoot\Temp\CitrixWorkspaceApp.exe"

        # Delete the target if it exists, so that we don't have issues
        If (Test-Path $Target) { Remove-Item -Path $Target -Force -ErrorAction SilentlyContinue }

        # Download Citrix Receiver locally
        Start-BitsTransfer -Source $Url -Destination $Target

        # Install Citrix Receiver
        If (Test-Path $Target) { Start-Process -FilePath $Target -ArgumentList "/AutoUpdateCheck=auto /Allowaaddstore=A /AutoUpdateStream=Current /DeferUpdateCount=5 /AURolloutPriority=Medium /NoReboot /Silent EnableCEIP=False" -Wait }
    }

# Clears the error log from powershell before exiting
    $error.clear()