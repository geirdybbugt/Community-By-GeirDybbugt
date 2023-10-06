####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

#Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $FSLogixDestination = "$Masterdestination\FSLogix"

#Folder Structure

    #Creating root folder
    MD $Masterdestination -force

    #Creating Subfolders
    MD $FSLogixDestination -force

#Windows search settings

    #Set windows search to auto/start
        $ServiceName = "WSearch"
        Set-Service -Name $ServiceName -StartupType Automatic -Verbose
    
        #Disable Delayed Auto Start
        Set-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Services\WSearch" -Name "DelayedAutoStart" -Value "0" -Verbose

    #Limit Windows search to 1 cpu core
        If (!(Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows Search" -Name "CoreCount"))
        {
        Write-Output "Windows Search registry fix" -Verbose
        New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows Search" -Name "CoreCount" -Value "1" -Type DWORD -Verbose
        }
        else
        {
            Write-Output "Windows Search registry fix exists" -Verbose
        }

    #Make sure windows search service is running before install
        $ServiceName = 'WSearch'
        $arrService = Get-Service -Name $ServiceName

        while ($arrService.Status -ne 'Running')
        {
            Start-Service $ServiceName
            write-host $arrService.status
            write-host 'Service starting'
            Start-Sleep -seconds 5
            $arrService.Refresh()
            if ($arrService.Status -eq 'Running')
            {
                Write-Host 'Search Service is now Running'
            }
        }
    
#FSLogix most recent version

    #Downloading source file
    Start-BitsTransfer -Source "https://aka.ms/fslogix_download" -Destination "$FSLogixDestination\FSLogix.zip"

    #Extracting package
    Expand-Archive "$FSLogixDestination\FSLogix.zip" -DestinationPath "$FSLogixDestination" -force

    #Get Extraxted Foldername
    $FolderName = Get-ChildItem $FSLogixDestination |where name -like "FSLogix_Ap*" |Select-Object -ExpandProperty name
       
    #Installing//Updating FSLogix
    start -wait "$FSLogixDestination\$FolderName\x64\Release\FSLogixAppsSetup.exe" "/quiet /norestart"  # <----- Edit this if your want the 32-bit installer.

#Deleting default members of Profile Container and Office 365 container groups (Default everyone is allowed)
#   NOTE: You can also insert the group you wish to grant access here with the net group /add command. 

    #Profile containers   
    net localgroup "FSLogix Profile Include List" everyone /delete

    #Office 365 containers
    net localgroup "FSLogix ODFC Include List" everyone /delete


# Windows search EventID2 workaround. Source: http://virtualwarlock.net/category/fslogix/
    # Define CIM object variables
    # This is needed for accessing the non-default trigger settings when creating a schedule task using Powershell
    $Class = cimclass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler
    $Trigger = $class | New-CimInstance -ClientOnly
    $Trigger.Enabled = $true
    $Trigger.Subscription = "<QueryList><Query Id=`"0`" Path=`"Application`"><Select Path=`"Application`">*[System[Provider[@Name='Microsoft-Windows-Search-ProfileNotify'] and EventID=2]]</Select></Query></QueryList>"

    # Define additional variables containing scheduled task action and scheduled task principal
    $A = New-ScheduledTaskAction –Execute powershell.exe -Argument "Restart-Service Wsearch"
    $P = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
    $S = New-ScheduledTaskSettingsSet

    # Cook it all up and create the scheduled task
    $RegSchTaskParameters = @{
        TaskName    = "Restart Windows Search Service on Event ID 2"
        Description = "Restarts the Windows Search service on event ID 2"
        TaskPath    = "\"
        Action      = $A
        Principal   = $P
        Settings    = $S
        Trigger     = $Trigger
    }

    Register-ScheduledTask @RegSchTaskParameters


#Cleaning up downloaded files
    start-sleep -Seconds 10
    remove-item $FSLogixDestination -recurse -Force
    remove-item $Masterdestination -recurse -Force