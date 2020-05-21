####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
####
#### Script is intended to install and setup a NPS server to be used for Azure MFA 
#### against Citrix ADC.
#### 
#### The script was made due to having to do the same process multiple times. So an export of a configured NPS server for Citrix ADC is expected. If you need a copy of the "Dummy" NPS xml export, you can reach out to me. 
#### 
#### PS PS!! : If using the Azure MFA extension, be sure to use a dedicated NPS server.
#### Failure to do so, may result in MFA prompts for other services on the same server
#### 
#### Azure MFA documentation source: https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-nps-extension
#### 
#### PS: need to run as Administrator
####------------------------------------------------------------------------####

#Require admin rights
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    if(!(New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){
	    Write-Error ("Please run the configuration script as administrator")
	    exit
}

#Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $NPSDummyDestination = "$Masterdestination\NPSConfig"
    
    #NPS Dummy XML file
    $DummyFileWebLocation = ""#<----- Input location for Dymmy NPS export xml file here. 

#Folder Structure

    #Creating root folder
    MD $Masterdestination -force

    #Creating Subfolders
    MD $NPSDummyDestination -force

#Install NPS Server Role
    Install-WindowsFeature NPAS -IncludeManagementTools

#Download and install Azure NPS Extension + Pre-reqs

	#Download Pre-req: Visual C++ Redistributable Packages for Visual Studio 2013
        $PreReqDownload = "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
        Start-BitsTransfer -Source "$PreReqDownload" -Destination "$NPSDummyDestination\vcredist_x64.exe"
    
        #Install Pre-req : Visual C++ Redistributable Packages for Visual Studio 2013
            Start-Process -wait "$NPSDummyDestination\vcredist_x64.exe" /quiet
          
          
	#Download Azure MFA NPS Extension
        $NPSExtensionDownload = "https://download.microsoft.com/download/B/F/F/BFFB4F12-9C09-4DBC-A4AF-08E51875EEA9/NpsExtnForAzureMfaInstaller.exe"
        Start-BitsTransfer -Source "$NPSExtensionDownload" -Destination "$NPSDummyDestination\NpsExtnForAzureMfaInstaller.exe"
        
        #Install: Azure MFA NPS Extension
            Start-Process -wait "NpsExtnForAzureMfaInstaller.exe" /quiet

#Start NPS Extension Config
    
    #Get Azure Ad Information
        $AzureAdIdentifier = Read-Host -Prompt 'Input Azure AD Identifier from the Azure AD Properties page'
    
    #Changing the downloaded AzureMfaNpsExtnConfigSetup.ps1 script to avoid having to type the Tenant ID multiple times
        (Get-Content "C:\Program Files\Microsoft\AzureMfa\Config\AzureMfaNpsExtnConfigSetup.ps1").replace("=Read-Host -Prompt 'Provide your Tenant ID For Self-Signed Certificate Creation'", '=$AzureAdIdentifier') | Set-Content "C:\Program Files\Microsoft\AzureMfa\Config\AzureMfaNpsExtnConfigSetup.ps1"
                    
    #Runs: Azure MFA NPS Extension setup script
        cls
        Write-host "Running Azure MFA NPS Extension setup script...."
        Write-host ""
        Write-host "Have Azure AD Identifier from the Azure AD Properties page ready"
        & "C:\Program Files\Microsoft\AzureMfa\Config\AzureMfaNpsExtnConfigSetup.ps1"
        

#Start NPS server config

    #Fetch NPS-Dummy export file
        Start-BitsTransfer -Source "$DummyFileWebLocation" -Destination "$NPSDummyDestination\NPS-Dummy.xml"
            
    #Customize NPS-Dummy XML File
        $IPSNIP = Read-Host -Prompt 'Input SNIP IP Address'
        $IPNPSSERVER = Read-Host -Prompt 'Input NPS Server IP Address'
        $RadiusSharedSecret = Read-Host -Prompt 'Input Radius Shared Secret'

    #Customize NPS XML file
        (Get-Content "$NPSDummyDestination\NPS-DUMMY.xml").replace('#IP-SNIP#', "$IPSNIP") | Set-Content "$NPSDummyDestination\NPS-DUMMY.xml"
        (Get-Content "$NPSDummyDestination\NPS-DUMMY.xml").replace('#SharedSecret#', "$RadiusSharedSecret") | Set-Content "$NPSDummyDestination\NPS-DUMMY.xml"
        (Get-Content "$NPSDummyDestination\NPS-DUMMY.xml").replace('#IP-NPS-Server#', "$IPNPSSERVER") | Set-Content "$NPSDummyDestination\NPS-DUMMY.xml"

            #Customizing done!
            Write-Host "XML customizing done!" 

    #Importer Config til NPS server
        Write-Host "Importing NPS Configuration" 
        Import-NpsConfiguration -Path "$NPSDummyDestination\NPS-DUMMY.xml"
        Write-Host "Import Completed"


#Info for documentation
    cls
    Write-Host "" 
    Write-Host "" 
    Write-Host "Config completed, keep the following for documentation.:" 
    Write-Host "" 
    Write-Host "" 
    Write-Host "Azure NPS Extension is configured agains the following Azure AD ID.: '$AzureAdIdentifier'" 
    Write-Host "" 
    Write-Host "The IP address for the NPS server is.: '$IPNPSSERVER'" 
    Write-Host "The SNIP IP Address used by NPS server is.: '$IPSNIP'" 
    Write-Host "The configured Radius Shared Secret is.: '$RadiusSharedSecret'" 
    Write-Host ""
    Write-Host "After saving the above information, press 'Enter' to clean-up and exit"
    Write-Host ""
    pause
    Write-Host "" 
    Write-Host "Performing Clean-up action in 5 seconds" 
    Write-Host "" 

#Cleaning up downloaded files
    start-sleep -Seconds 5

    #Remove Variables
    Remove-Variable -Name DummyFileWebLocation
    Remove-Variable -Name NPSDummyDestination
    Remove-Variable -Name Masterdestination
    Remove-Variable -Name PreReqDownload
    Remove-Variable -Name NPSExtensionDownload
    Remove-Variable -Name IPSNIP
    Remove-Variable -Name IPNPSSERVER
    Remove-Variable -Name RadiusSharedSecret
    Remove-Variable -Name AzureAdIdentifier

    #Remove files
    Remove-Item $NPSDummyDestination -Recurse -Force
    remove-item $Masterdestination -recurse -Force

    cls
        
    Write-Host "" 
    Write-Host "" 
    Write-Host "Clean-up complete, press Enter to Exit!" 
    Write-Host "" 
    Write-Host "" 
    Pause