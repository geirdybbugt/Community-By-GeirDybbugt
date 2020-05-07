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

#Office 365 Click to run - most recent version

#Downloading source file

    $Office365Download = ((Invoke-WebRequest -Uri 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117' ).Links | Where innerHTML -like "*click here to download manually*").href
    Start-BitsTransfer -Source $Office365Download -Destination "$Office365Destination"

#Extracting package

    $OfficeFilename = Get-ChildItem -path $Office365Destination | where name -like "officedeploymenttool*" | Select-Object
    start-process $OfficeFilename.Fullname -Argumentlist "/extract:$Office365Destination /quiet" 

#Delete standard xml files and installer archive

    start-sleep -Seconds 5
    Remove-Item $Office365Destination\$OfficeFilename -force
    remove-item $Office365Destination\*.xml -force

#Get customization file

    Start-BitsTransfer -source "$Office365xmlSourceFiles" -Destination $Office365Destination

    ## start installation

    cd $Office365Destination
    .\setup.exe /download "$Office365xmlSourceFiles"
	.\setup.exe /configure "$Office365xmlSourceFiles"
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