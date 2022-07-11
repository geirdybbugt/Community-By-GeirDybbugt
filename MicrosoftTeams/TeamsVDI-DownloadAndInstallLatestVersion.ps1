<#------------------------------------------------------------------------
Downloads and install Microsoft Teams x64 for VDI
Can be run later to update packages
 
Creator info: Geir Dybbugt - https://dybbugt.no
Modified - 28.03.2022
---------------------------------------------------------------------------#>

# Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $TeamsDestination = "$Masterdestination\Teams"

# Folder Structure

    # Creating root folder
    MD $Masterdestination -force

    # Creating Subfolders
    MD $TeamsDestination -force

    # Temp path for FSLogix rules 
    $temppath = "c:\fsltemp"

# Move rules to temp before install/update    
    if(!(test-path $temppath)){
    write-host "not exist"
    md $temppath
    Move-Item "C:\Program Files\FSLogix\Apps\Rules\*.*" "C:\fsltemp"
    } else {
    write-host "exist"
    Move-Item "C:\Program Files\FSLogix\Apps\Rules\*.*" "C:\fsltemp"
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
	
 # Set TLS protocol type
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

 # Downloading source file
    $TeamsDownload = ((Invoke-WebRequest -Uri 'https://docs.microsoft.com/en-us/microsoftteams/teams-for-vdi' -UseBasicParsing ).Links | where outerHTML -Like "*64-bit version*").href
    $TeamsDownload = $TeamsDownload -replace "&","&"
    Start-BitsTransfer -Source $TeamsDownload -Destination "$TeamsDestination\teams.msi"

  # start installation
    cd $TeamsDestination
    start-process msiexec.exe -argumentlist "/i `"$TeamsDestination\teams.msi`"  ALLUSER=1 ALLUSERS=1" -wait
    cd \

# Prevent Teams from autostarting 	 

	# Change the JSON config files for autostart 
		$JSON = "${env:ProgramFiles(x86)}\Microsoft\Teams\setup.json"
		$JSON2 = "${env:ProgramFiles(x86)}\Teams Installer\setup.json"
	 
	 # Change Teams noAutoStart from false to true
		(Get-Content $JSON).replace('"noAutoStart":false', '"noAutoStart":true') | Set-Content $JSON
		(Get-Content $JSON2).replace('"noAutoStart":false', '"noAutoStart":true') | Set-Content $JSON2
		
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

# Move FSLogix rules back to folder
    Move-Item "C:\fsltemp\*.*" "C:\Program Files\FSLogix\Apps\Rules\"
    Remove-Item C:\fsltemp -Force

 
# Cleaning up downloaded files
	start-sleep -Seconds 10
	remove-item $TeamsDestination -recurse -Force
	remove-item $Masterdestination -recurse -Force

# Clears the error log from powershell before exiting
    $error.clear()