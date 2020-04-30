####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
#### Script is intended for install on VDI - Hence the /allusers parameter
####------------------------------------------------------------------------####

#Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $OneDriveDestination = "$Masterdestination\OneDrive"
    $OneDriveRegistry = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe"


#Folder Structure

    #Creating root folder
    MD $Masterdestination -force

    #Creating Subfolders
    MD $OneDriveDestination -force

#Microsoft OneDrive for Business Latest Stable Version
    
    #Getting the download url  from MS API site (https://edgeupdates.microsoft.com/api/products?view=enterprise)
    $OneDriveDownload = ((Invoke-WebRequest -Uri 'https://www.microsoft.com/nb-no/microsoft-365/onedrive/download' ).Links | Where innerHTML -like "*Last ned*").href  # <<--- URL is for norway change nb-no in url to en-us for english
        
    #Downloading source file
    Start-BitsTransfer -Source $OneDriveDownload -Destination "$OneDriveDestination\OneDriveSetup.exe"

    ## start installation
    cd $OneDriveDestination
    .\OneDriveSetup.exe /allusers
	cd \
    
    #Waiting for installation to complete
    while (-not (Test-Path -Path $OneDriveRegistry)) {
    Start-Sleep -Seconds 5
    }
    
#Post install script

    #Removing scheduled tasks
        $OneDriveScheduledTasks = "OneDrive Per-Machine Standalone Update Task"
        ForEach ($Task in $OneDriveScheduledTasks)
        {
        Unregister-ScheduledTask -TaskName $Task -Confirm:$false
        }
        
    #Cleaning up downloaded files
        start-sleep -Seconds 10
        Remove-Item $OneDriveDestination -Recurse -Force
        remove-item $Masterdestination -recurse -Force