<#------------------------------------------------------------------------
 Downloads and install Buypass Javafree
 Can be run later to update packages

 Creator info: Geir Dybbugt - https://dybbugt.no
 Modified - 27.02.2022
 ------------------------------------------------------------------------####>
 
# Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $JavafreeDestination = "$Masterdestination\Javafri"
    $JavafreeRegistry = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"

# Folder Structure

    # Creating root folder
    MD $Masterdestination -force

    # Creating Subfolders
    MD $JavafreeDestination -force

# Microsoft Edge for Business Latest Stable Version
    $DownloadSource = "https://www.buypass.com/help/smart-card/javafree/how-to-install-javafree"
    $Getlink = ((Invoke-WebRequest -Uri 'https://www.buypass.com/help/smart-card/javafree/how-to-install-javafree' -UseBasicParsing ).Links | where outerHTML -Like "*.exe*").href  | Select-Object -First 1
    $DownloadLink = "$DownloadSource" + "$Getlink"

# Start download
    Start-BitsTransfer -Source $downloadlink -Destination "$JavafreeDestination\javafri.exe"
             
        #Get filename
            $GetFullPath = Get-ChildItem -Path $JavafreeDestination -Filter *.exe
            $fullpathinstaller = $GetFullPath.fullname

        #Installing//Updating 7Zip
            start-process -wait $fullpathinstaller /S

    # Remove from autostart
        <#removes the following registry item: 
            Path : HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run
            Name: Buypass Javafree
            Value: "C:\Program Files (x86)\Buypass\Javafree\Buypass.SCProxy.exe"
            Type: REG_SZ
            #>
	    Remove-ItemProperty -Path "$JavafreeRegistry" -Name "Buypass Javafree"
                
#Cleaning up downloaded files
    start-sleep -Seconds 5
    Remove-Item $JavafreeDestination -Recurse -Force
    remove-item $Masterdestination -recurse -Force
