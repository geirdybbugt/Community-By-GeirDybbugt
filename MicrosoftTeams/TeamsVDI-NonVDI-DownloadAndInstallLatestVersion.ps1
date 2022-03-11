<#------------------------------------------------------------------------
Downloads and install Microsoft Teams x64 for VDI
Can be run later to update packages
 
Creator info: Geir Dybbugt - https://dybbugt.no
Modified - 28.02.2022
---------------------------------------------------------------------------#>

# Variables
$Masterdestination = "$env:APPDATA\DybbugtNO-Files"
$TeamsDestination = "$Masterdestination\Teams"

# Folder Structure

    # Creating root folder
    MD $Masterdestination -force

    # Creating Subfolders
    MD $TeamsDestination -force
	
# Set TLS protocol type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

 # Downloading source file
    $TeamsDownload = ((Invoke-WebRequest -Uri 'https://docs.microsoft.com/en-us/microsoftteams/teams-for-vdi' -UseBasicParsing ).Links | where outerHTML -Like "*64-bit version*").href
    $TeamsDownload = $TeamsDownload -replace "&amp;","&"
        Start-BitsTransfer -Source $TeamsDownload -Destination "$TeamsDestination\teams.msi"

# Add VDI isntall requirement if not there
    # Variables
        $RegPath = "HKLM:\Software\Citrix\PortICA"
        
        if((Test-Path -LiteralPath $RegPath) -ne $true) {
            New-Item $RegPath -force
                if ($?) {
                    new-ItemProperty -LiteralPath "$RegPath" -Name 'ALLUSER' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
                    } else {
                    write-host "failed" -ForegroundColor Red
                    }
            } else {
                new-ItemProperty -LiteralPath "$RegPath" -Name 'ALLUSER' -Value '1'-PropertyType String -Force -ea SilentlyContinue;
            }
 
  # start installation
    cd $TeamsDestination
    start-process msiexec.exe -argumentlist "/i `"$TeamsDestination\teams.msi`"  ALLUSER=1 ALLUSERS=1" -wait
    cd \

# Remove registry keys to stop Teams from autostarting
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Teams"

# Remove shortcut public desktop
    $ShortcutPath = "C:\Users\Public\Desktop\Microsoft Teams.lnk"
    if((test-path $ShortcutPath) -eq $true) {
    remove-item -Path $ShortcutPath -Force
    }

# Stopping Outlook to register the Teams Addin modules
    Write-Host ""
    Write-host "Need to close Outlook to register the Teams Adding for Outlook - press a key to close Outlook" -ForegroundColor Cyan
    Write-host ""
    Pause
    Write-Host "Stopping Outlook Process" -ForegroundColor Yellow
        try{
            Get-Process -ProcessName Outlook | Stop-Process -Force
            Start-Sleep -Outlook 3
            Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
        }catch{
            echo $_
        }

    Write-host "Registering Teams Addin for Outlook" -ForegroundColor Yellow
        $TeamsAddinFolderName = Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft\TeamsMeetingAddin"  | Select-Object -ExpandProperty Fullname  
        regsvr32.exe /n /i /s "$TeamsAddinFolderName\x64\Microsoft.Teams.AddinLoader.dll" 
        regsvr32.exe /n /i /s "$TeamsAddinFolderName\x86\Microsoft.Teams.AddinLoader.dll" 

  
  # Cleaning up downloaded files
    start-sleep -Seconds 10
    remove-item $TeamsDestination -recurse -Force
    remove-item $Masterdestination -recurse -Force

# Clears the error log from powershell before exiting
    $error.clear()