####------------------------------------------------------------------------####
#### Downloads and install Microsoft Teams x64 for VDI
#### Can be run later to update packages
#### 
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

#Variables
$Masterdestination = "$env:APPDATA\DybbugtNO-Files"
$TeamsDestination = "$Masterdestination\Teams"

#Folder Structure

    #Creating root folder
    MD $Masterdestination -force

    #Creating Subfolders
    MD $TeamsDestination -force

 #Downloading source file
    $TeamsDownload = ((Invoke-WebRequest -Uri 'https://docs.microsoft.com/en-us/microsoftteams/teams-for-vdi' -UseBasicParsing ).Links | where outerHTML -Like "*64-bit version*").href
    Start-BitsTransfer -Source $TeamsDownload -Destination "$TeamsDestination"

 #start installation
    cd $TeamsDestination
    msiexec /i "$TeamsDestination\teams_windows_x64.msi" ALLUSER=1 ALLUSERS=1
    cd \
 
  #Cleaning up downloaded files
    start-sleep -Seconds 10
    remove-item $TeamsDestination -recurse -Force
    remove-item $Masterdestination -recurse -Force