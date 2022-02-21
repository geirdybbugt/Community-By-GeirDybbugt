<#------------------------------------------------------------------------
NOTE: 
            This package reverts the bugfix from 2022 issues back to normal per machine installer with updates enabled and cleans away the non vdi requirements.
            This makes is easy for the users to jump back to a normal installation of Teams after the issue has been resolved. 


            The 2022 Bug is descriped here - https://dybbugt.no/2022/2067/
NOTE End
------------------------------------
 
 This script will: 

 - Stop running Teams
 - Uninstall existing versions (machin installer and user installer)
 - Clear the Teams Cache from user profiles
 - Remove the needed registry key to be able to install the VDI installer to NON-VDI machines
 - Download the latest MSI based  installer from Microsoft for x64. 
 - Install it onto the machine
 - Start Teams when installed to inject it into the users profile for user based installation as normal

 
 Creator info: Geir Dybbugt - https://dybbugt.no
 Modified - 21.02.2022
------------------------------------------------------------------------####>

# Set console window title
    $host.ui.RawUI.WindowTitle = "Dybbugt.no - Revert - Teams 1.4 For VDI on NonVDI - 2022 Bugfix - https://dybbugt.no/2022/2067/"

# Info
    Write-host ""
    Write-host "Reverting back to the normal Microsoft Teams installation - cleaning up temporary Bugfix installation" -ForegroundColor Green
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
    function uninstallTeams($path) {
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

    # Remove remaining old Teams Cache folders from previous install - before installing. 

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

    # Cleaning Web browser caches

        # Google Chrome
            Write-Host ""
            Write-Host "Cleaning Google Chrome Cache" -ForegroundColor Cyan
            Write-Host "Stopping Chrome Process" -ForegroundColor Yellow
                try{
                    Get-Process -ProcessName Chrome| Stop-Process -Force
                    Start-Sleep -Seconds 3
                    Write-Host "Chrome Process Sucessfully Stopped" -ForegroundColor Green
                }catch{
                    echo $_
                }
                Write-Host "Clearing Google Chrome Cache" -ForegroundColor Yellow
    
                try{
                    Get-ChildItem -Path $env:LOCALAPPDATA"\Google\Chrome\User Data\Default\Cache" | Remove-Item -force -Recurse
                    Get-ChildItem -Path $env:LOCALAPPDATA"\Google\Chrome\User Data\Default\Cookies" -File | Remove-Item -force
                    Get-ChildItem -Path $env:LOCALAPPDATA"\Google\Chrome\User Data\Default\Web Data" -File | Remove-Item -force
                    Write-Host "Google Chrome Cache Cleared!" -ForegroundColor Green
                }catch{
                    echo $_
                }

        # Edge Chromium
            Write-Host ""
            Write-Host "Cleaning Edge Chromium Cache" -ForegroundColor Cyan
            Write-Host "Stopping Edge Chromium Process" -ForegroundColor Yellow
                try{
                    Get-Process -ProcessName msedge| Stop-Process -Force
                    Start-Sleep -Seconds 3
                    Write-Host "Edge Chromium Process Sucessfully Stopped" -ForegroundColor Green
                }catch{
                    echo $_
                }
                Write-Host "Clearing Edge Chromium Cache" -ForegroundColor Yellow
  
                try{
                    Get-ChildItem -Path $env:LOCALAPPDATA"\Microsoft\Edge\User Data\Default\Cache" | Remove-Item -Force -Recurse
                    Get-ChildItem -Path $env:LOCALAPPDATA"\Microsoft\Edge\User Data\Default\Cookies" -File | Remove-Item -force
                    Get-ChildItem -Path $env:LOCALAPPDATA"\Microsoft\Edge\User Data\Default\Web Data" -File | Remove-Item -force
                    Write-Host "Edge Chromium Cache Cleared!" -ForegroundColor Green
                }catch{
                    echo $_
                }

        # IE and Edge
            Write-Host ""
            Write-Host "Cleaning Edge and Internet Explorer Cache" -ForegroundColor Cyan
            Write-Host "Stopping IE Process" -ForegroundColor Yellow
    
            try{
                Get-Process -ProcessName MicrosoftEdge | Stop-Process -Force
                Get-Process -ProcessName IExplore | Stop-Process -Force
                Write-Host "Internet Explorer and Edge Processes Sucessfully Stopped" -ForegroundColor Green
            }catch{
                echo $_
            }
            Write-Host "Clearing IE Cache" -ForegroundColor Yellow
    
            try{
                RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8
                RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 2
                Write-Host "IE and Edge Cache Cleared!" -ForegroundColor Green
                Write-Host ""
            }catch{
                echo $_
            }
 
# Set TLS protocol type
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Downloading source file
    Write-Host "Downloading Teams installation" -ForegroundColor Cyan
    $TeamsDownload = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
        if((Test-Path "$TeamsDestination\teams.msi") -eq $true) {
        remove-item -path "$TeamsDestination\teams.msi" -force
        }
        Start-BitsTransfer -Source $TeamsDownload -Destination "$TeamsDestination\teams.msi"

  # start installation
    Write-Host "Installing Microsoft Teams" -ForegroundColor Yellow
    cd $TeamsDestination
    start-process msiexec.exe -argumentlist "/i `"$TeamsDestination\teams.msi`" ALLUSERS=1" -wait
    cd \
    Write-Host "Microsoft Teams installed!" -ForegroundColor Green

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
    $teamspath = "${env:ProgramFiles(x86)}\Teams Installer"
    $teamsexe = "Teams.exe"

    Write-Host "Starting Microsoft Teams" -ForegroundColor Green
    Start-process -FilePath "$teamspath\$teamsexe"

# Clears the error log from powershell before exiting
    $error.clear()