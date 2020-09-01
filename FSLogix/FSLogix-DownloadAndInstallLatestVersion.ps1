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

    #Installing//Updating FSLogix
    start -wait "$FSLogixDestination\x64\Release\FSLogixAppsSetup" "/quiet /norestart"  # <----- Edit this if your want the 32-bit installer. 

#Deleting default members of Profile Container and Office 365 container groups (Default everyone is allowed)
#   NOTE: You can also insert the group you wish to grant access here with the net group /add command. 

    #Profile containers   
    net localgroup "FSLogix Profile Include List" everyone /delete

    #Office 365 containers
    net localgroup "FSLogix ODFC Include List" everyone /delete


#Cleaning up downloaded files
    start-sleep -Seconds 10
    remove-item $FSLogixDestination -recurse -Force
    remove-item $Masterdestination -recurse -Force