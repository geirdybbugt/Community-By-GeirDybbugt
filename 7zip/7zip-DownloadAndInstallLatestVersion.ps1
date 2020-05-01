####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
#### Download and install latest version (x86 Exe installer)
####------------------------------------------------------------------------####

    #Variables
        $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
        $7zipDestination = "$Masterdestination\7zip"
     
    #Folder Structure

        #Creating root folder
        MD $Masterdestination -force

        #Creating Subfolders
        MD $7zipDestination -force
    
    #7Zip recent version
        
        #Get link
        $APIURL = Invoke-restmethod "https://sourceforge.net/projects/sevenzip/best_release.json"
        $DownloadLink = $APIURL.Release | Select-Object -ExpandProperty url 
        
        #Downloading source file
        Start-BitsTransfer -Source "$DownloadLink" -Destination "$7zipDestination\7zip.exe"
         
        #Get filename
        $GetFullPath = Get-ChildItem -Path $7zipdestination -Filter *.exe
        $fullpathinstaller = $GetFullPath.fullname

        #Installing//Updating 7Zip
        start-process -wait $fullpathinstaller /S
                
    #Cleaning up downloaded files
        start-sleep -Seconds 5
        Remove-Item $7zipDestination -Recurse -Force
        remove-item $Masterdestination -recurse -Force
