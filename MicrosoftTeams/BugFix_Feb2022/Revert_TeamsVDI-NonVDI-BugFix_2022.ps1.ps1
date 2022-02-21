<#------------------------------------------------------------------------
NOTE: 
            This package reverts the bugfix from 2022 issues back to normal per machine installer with updates enabled and cleans away the non vdi requirements.
            This makes is easy for the users to jump back to a normal installation of Teams after the issue has been resolved. 
NOTE End
------------------------------------
 This package was created due to an apparent bug on Microsoft Teams introduced in the 1.5 release from Microsoft. 
 Users are experiencing issues with calling, conferencing etc after update to 1.5.2164 version of Teams. 
 Issues revolve around the functionality is just not working, gives error etc. 
 Downgrading to 1.4 resolves the issue. But, Teams gets auto updated. 

 Users especcially affected are users with devices controlled via Endpoint Manager/intune Azure join etc. 
 Users then typically has a Display Name set on their users in Azure including "(Something)" i.e "John Smith (Sales)". 
 Azure uses this to generate the folder name for the local user profiles giving issues to some users with long names. 
 This results in the folder getting a name with a non enclosing parenthesis like so: "John Smith(" - this seems to break functionality with some apps, including Teams after 1.5.x release. 

 Note for Microsoft - if the somehow sees this - please use Alias/identity or anything other than Display Name  to generate this folder name - Display nNme is not suited for this.
 Display name can also include special characters or non english characthers that also can cause challanges down the road.  

 A workaround to this problem for now, is to use the VDI installer, this installer has auto updated disabled when installed correctly.
 But, to install the VDI installer onto Non-VDI machines some tweaks need to be made. 

 This script will: 
 - Stop running Teams
 - Uninstall existing versions (machin installer and user installer)
 - Clear the Teams Cache from user profiles
 - Set the needed registry key to be able to install the VDI installer to NON-VDI machines
 - Download the MSI based VDI installer from Microsoft version 1.4.00.2781 for x64. 
 - Install it onto the machine
 - Start Teams when installed

 Auto updates is then disabled until permanent fix from Microsoft is available in the normal installer.   


 
 Creator info: Geir Dybbugt - https://dybbugt.no
 Modified - 18.02.2022

 Refrences talking about the issues: 

 https://techcommunity.microsoft.com/t5/microsoft-teams/teams-version-1-5-00-2164-bug/m-p/3150143
 https://docs.microsoft.com/en-us/answers/questions/730769/teams-version-15002164-bug.html
 https://www.theregister.com/2022/02/15/microsoft_teams_outage/
------------------------------------------------------------------------####>

# Set console window title
    $host.ui.RawUI.WindowTitle = "Dybbugt.no - Teams 1.4 For VDI on NonVDI - 2022 Bugfix - https://dybbugt.no/2022/2067/"

# Info
    Write-host ""
    Write-host "Problem as described in details on the post found here 'https://dybbugt.no/2022/2067/'" -ForegroundColor Green
    Write-host ""
    Write-host ""

# Stop Teams if currently running
    Write-host "Starting bugfix" -ForegroundColor Cyan
    Write-Host "Stopping Teams Process" -ForegroundColor Yellow
        try{
            Get-Process -ProcessName Teams | Stop-Process -Force
            Start-Sleep -Seconds 3
            Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
        }catch{
            echo $_
        }

# Look for and remove existing Teams installers
# Machine Installer
    Write-Host "Removing Teams Machine-wide Installer" -ForegroundColor Yellow
    $MachineWide = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Teams Machine-Wide Installer"}
    $MachineWide.Uninstall() | out-null

# Function to uninstall Teams
    function unInstallTeams($path) {
    $clientInstaller = "$($path)\Update.exe"
  
   try {
        $process = Start-Process -FilePath "$clientInstaller" -ArgumentList "--uninstall /s" -PassThru -Wait -ErrorAction STOP
        if ($process.ExitCode -ne 0)
    {
      Write-Error "UnInstallation failed with exit code  $($process.ExitCode)."
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
    }

# Locate User installation folder
    $localAppData = "$($env:LOCALAPPDATA)\Microsoft\Teams"
    $programData = "$($env:ProgramData)\$($env:USERNAME)\Microsoft\Teams"
   
        If (Test-Path "$($localAppData)\Current\Teams.exe") 
        {
          unInstallTeams($localAppData)
    
        }
        elseif (Test-Path "$($programData)\Current\Teams.exe") {
          unInstallTeams($programData)
        }
        else {
          Write-Warning  "Teams installation not found"
        }

# Get and install the VDI based installer
    # Variables
        $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
        $TeamsDestination = "$Masterdestination\Teams"

# Folder Structure
    # Creating root folder
        MD $Masterdestination -force | Out-Null

    # Creating Subfolders
        MD $TeamsDestination -force| Out-Null
	
# Remove VDI Install requirement if there
    # Variables
        $RegPath = "HKLM:\Software\Citrix\PortICA"
        
        if((Test-Path -LiteralPath $RegPath) -eq $true) {
            Remove-Item $RegPath -Recurse -Force
            } else {
            write-host "VDI install requirement does not exist, continuing" -ForegroundColor Green
            }

    # Remove remaining old Teams Cache folders from previous install - before installing the VDI based installer. 

        # Remove the all users' cache. This reads all user subdirectories in each user folder matching
        # all folder names in the cache and removes them all
            Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Teams\*" -Directory | `
	            Where-Object Name -in ('application cache','blob_storage','cache','databases','GPUcache','IndexedDB','Local Storage','tmp') | `
	            ForEach {Remove-Item $_.FullName -Recurse -Force}

        # Remove every user's cache. This reads all subdirectories in the $env:APPDATA\Microsoft\Teams folder matching
        #  all folder names in the cache and removes them all
            Get-ChildItem -Path "$env:APPDATA\Microsoft\Teams\*" -Directory | `
	            Where-Object Name -in ('application cache','blob storage','cache','databases','GPUcache','IndexedDB','Local Storage','tmp') | `
	            ForEach {Remove-Item $_.FullName -Recurse -Force}
 
# Set TLS protocol type
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Downloading source file
    $TeamsDownload = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
        if((Test-Path "$TeamsDestination\teams.msi") -eq $true) {
        remove-item -path "$TeamsDestination\teams.msi" -force
        }
        Start-BitsTransfer -Source $TeamsDownload -Destination "$TeamsDestination\teams.msi"

  # start installation
    cd $TeamsDestination
    start-process msiexec.exe -argumentlist "/i `"$TeamsDestination\teams.msi`" ALLUSERS=1" -wait
    cd \

# Remove registry keys to stop Teams from autostarting
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Teams"| Out-Null

# Remove shortcut public desktop
    $ShortcutPath = "C:\Users\Public\Desktop\Microsoft Teams.lnk"
    if((test-path $ShortcutPath) -eq $true) {
    remove-item -Path $ShortcutPath -Force
    }
  
# Cleaning up downloaded files
    start-sleep -Seconds 5
    remove-item $TeamsDestination -recurse -Force
    remove-item $Masterdestination -recurse -Force

# Start teams installer first time to load into profile for the user
    start-process -FilePath "C:\Program Files (x86)\Teams Installer\teams.exe"

# Clears the error log from powershell before exiting
    $error.clear()

# exit
    exit