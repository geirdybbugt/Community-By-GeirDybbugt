﻿####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
#### Citrix API hook and Update/tasks parts from @KasperMJohansen over at https://virtualwarlock.net/microsoft-edge-in-citrix/
#### Script is intended for install on VDI - Hence the Citrix/tasks/etc parts
####------------------------------------------------------------------------####

#Variables
    $Masterdestination = "$env:APPDATA\DybbugtNO-Files"
    $EdgeDestination = "$Masterdestination\MSEdge"
    $EdgeRegistry = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"

#Folder Structure

    #Creating root folder
    MD $Masterdestination -force

    #Creating Subfolders
    MD $EdgeDestination -force

#Microsoft Edge for Business Latest Stable Version
    
    #Getting the download url  from MS API site (https://edgeupdates.microsoft.com/api/products?view=enterprise)

		#Set TLS protocol type
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
    $APIURL = Invoke-restmethod "https://edgeupdates.microsoft.com/api/products"
    $EdgeDownloadLink = $APIURL.Releases | Select-Object -ExpandProperty Artifacts | Where location -Like "*MicrosoftEdgeEnterpriseX64.msi*" | Select-Object -ExpandProperty location 
    
    #Downloading source file
    Start-BitsTransfer -Source "$EdgeDownloadLink" -Destination "$EdgeDestination\MicrosoftEdgeEnterpriseX64.msi"

    #Installing//Updating Microsoft Edge for Business
    MSIEXEC /i "$EdgeDestination\MicrosoftEdgeEnterpriseX64.msi" /qn DONOTCREATEDESKTOPSHORTCUT=TRUE

    #Waiting for installation to complete
    while (-not (Test-Path -Path $EdgeRegistry)) {
    Start-Sleep -Seconds 5
    }

#For Citrix! - add MSEdge to UviProcessExcludes to prevent Citrix API hooks from latching on to MS Edge process
#Source: https://virtualwarlock.net/microsoft-edge-in-citrix/
        $RegPath = "HKLM:SYSTEM\CurrentControlSet\services\CtxUvi"
        $RegName = "UviProcessExcludes"
        $EdgeRegvalue = "msedge.exe;msedgewebview2.exe;msedgewebview2"
        # "msedgewebview" is added shortened as there is a 14 char limit on the process names. REF: https://support.citrix.com/article/CTX107825/how-to-disable-citrix-api-hooks-on-a-perapplication-basis

        # Get current values in UviProcessExcludes
        $CurrentValues = Get-ItemProperty -Path $RegPath | Select-Object -ExpandProperty $RegName

        # Add the msedge.exe value to existing values in UviProcessExcludes
        Set-ItemProperty -Path $RegPath -Name $RegName -Value "$CurrentValues$EdgeRegvalue;"

        $RegPath = "HKLM:SOFTWARE\Citrix\CtxHook"
        $RegName = "ExcludedImageNames"
        $Values = "msedge.exe,msedgewebview2.exe"
        New-ItemProperty -Path $RegPath -Name $RegName -PropertyType ExpandString -Value $Values

        $RegPath = "HKLM:SOFTWARE\Wow6432Node\Citrix\CtxHook"
        $RegName = "ExcludedImageNames"
        New-ItemProperty -Path $RegPath -Name $RegName -PropertyType ExpandString -Value $Values

        $RegPath = "HKLM:SOFTWARE\Wow6432Node\Citrix\CtxHook64"
        $RegName = "ExcludedImageNames"
        New-ItemProperty -Path $RegPath -Name $RegName -PropertyType ExpandString -Value $Values


#Microsoft Edge post-install script
#Source: https://virtualwarlock.net/microsoft-edge-in-citrix/

        # Stop and disable Microsoft Edge services
        $Services = "edgeupdate","MicrosoftEdgeElevationService"
        ForEach ($Service in $Services)
        {
        If ((Get-Service -Name $Service).Status -eq "Stopped")
        {
        Set-Service -Name $Service -StartupType Disabled
        }
        else
        {
        Stop-Service -Name $Service -Force -Verbose
        Set-Service -Name $Service -StartupType Disabled
        }
        }

        # Delete Microsoft Edge scheduled tasks
        $EdgeScheduledTasks = "MicrosoftEdgeUpdateTaskMachineCore","MicrosoftEdgeUpdateTaskMachineUA","MicrosoftEdgeUpdateBrowserReplacementTask","MicrosoftEdgeUpdateTaskMachineCore","MicrosoftEdgeUpdateTaskMachineUA"
        ForEach ($Task in $EdgeScheduledTasks)
        {
        Unregister-ScheduledTask -TaskName $Task -Confirm:$false
        }

        # Remove Microsoft Edge shortcut on Public Desktop
        Remove-Item -Path "$env:PUBLIC\Desktop\Microsoft Edge.lnk"


#Cleaning up downloaded files
    start-sleep -Seconds 5
    remove-item $EdgeDestination -recurse -Force
    remove-item $Masterdestination -recurse -Force