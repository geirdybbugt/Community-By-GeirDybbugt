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
    
#FSLogix recent version

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