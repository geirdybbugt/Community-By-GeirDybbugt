<###------------------------------------------------------------------------
#### Downloads and install Latest version of KeePass 2.x
#### Can be run later to update 
#### Intended for deployment via Intune
####
#### Source files is scraped via official channels.:  https://keepass.info/download.html
####
#### Creator info: Geir Dybbugt - https://dybbugt.no
#### Updated 17.02.2022
####------------------------------------------------------------------------#>

#Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $KeePassDestination = "$Masterdestination\KeePass"
     
#Folder Structure

    #Creating root folder
        MD $Masterdestination -force

    #Creating Subfolders
        MD $KeePassDestination -force

#Set TLS protocol type
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12   

#Downloading source file
    $KeePassDownloadSource = ((Invoke-WebRequest -Uri 'https://keepass.info/download.html' -UseBasicParsing ).Links | where outerHTML -Like "*.msi*").href # <-- Change to .exe if you want to swap for exe installer. 
    $KeePassDownloadLink = $KeePassDownloadSource | sort -Descending |Select-Object -Index 0 
    $KeePassDownloadLink

    #Downloads the newest installer
        Start-BitsTransfer -Source $KeePassDownloadLink -Destination "$KeePassDestination\keepass.msi"

 #start installation - MSI based - adapt if you are going to use .exe installer. 
    cd $KeePassDestination
    start-process msiexec.exe -argumentlist "/i `"$KeePassDestination\keepass.msi`" /quiet" -wait
                
#Cleaning up downloaded files
    start-sleep -Seconds 5
    Remove-Item $KeePassDestination -Recurse -Force
    remove-item $Masterdestination -recurse -Force

    # Clears the error log from powershell before exiting
    $error.clear()