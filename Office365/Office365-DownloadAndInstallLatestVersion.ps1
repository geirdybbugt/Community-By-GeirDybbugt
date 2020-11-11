####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

#Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $Office365Destination = "$Masterdestination\Office365"
    $Office365xmlSourceFiles = ""  # <--- SET LOCATION FOR YOUR XML CONFIG FILE HERE

#Folder Structure

    #Creating root folder
    MD $Masterdestination -force

    #Creating Subfolders
    MD $Office365Destination -force
	
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

#Office 365 Click to run - most recent version

#Downloading source file

    $Office365Download = ((Invoke-WebRequest -Uri 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117' -UseBasicParsing).Links | Where outerHTML -like "*click here to download manually*").href
    Start-BitsTransfer -Source $Office365Download -Destination "$Office365Destination"

#Extracting package

    $OfficeFilename = Get-ChildItem -path $Office365Destination | where name -like "officedeploymenttool*" | Select-Object
    start-process $OfficeFilename.Fullname -Argumentlist "/extract:$Office365Destination /quiet" 

#Delete standard xml files and installer archive

    start-sleep -Seconds 5
    Remove-Item $Office365Destination\$OfficeFilename -force
    remove-item $Office365Destination\*.xml -force

#Select customization file if variable in top is not set 

    IF([string]::IsNullOrEmpty($Office365xmlSourceFiles)) { 
        write-host "XML file not provided, opening file prompt.. " -ForegroundColor Cyan          
        write-host "XML file can be created on the web here: 'https://config.office.com/deploymentsettings'" -ForegroundColor Yellow       
	        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
	        InitialDirectory = [Environment]::GetFolderPath('Desktop')
	        Filter = 'XMLFile (*.xml)|*.xml'
	        }
            $FileBrowser.title = "Select your Office 365 XML configuration file" 
            $result = $FileBrowser.showdialog()
        If($result -eq "OK") {
            $Office365xmlSourceFiles = $filebrowser.FileName
            write-host "Configuration file selected is $Office365xmlSourceFiles" -ForegroundColor green
            } else {
                Write-host ""
                Write-host "User aborted, stopping installation!" -ForegroundColor red
                Write-host ""
                break
                }
        } 

#Get customization file

    Start-BitsTransfer -source "$Office365xmlSourceFiles" -Destination $Office365Destination

    ## start installation

    cd $Office365Destination
    .\setupodt.exe /download "$Office365xmlSourceFiles"
	.\setupodt.exe /configure "$Office365xmlSourceFiles"
    cd \

#For VDI: Removing scheduled tasks - PS!!: Remove if not deploying for VD/NonPersistent machines
    $Office365ScheduledTasks = "Office Automatic Updates 2.0","Office Feature Updates","Office Feature Updates Logon"
    ForEach ($Task in $Office365ScheduledTasks)
    {
    Unregister-ScheduledTask -TaskName $Task -Confirm:$false
    }
        
#Cleaning up downloaded files
    start-sleep -Seconds 10
    Remove-Item $Office365Destination -Recurse -Force
    remove-item $Masterdestination -recurse -Force
    write-host "Install completed" -ForegroundColor Cyan