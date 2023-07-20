<#
Script to set device url for kiosk pr device based on serial number
The CSV file is located in Azure Storage blob
update: 13:30 01.03.2023
#>

# Restart Process using PowerShell 64-bit 
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}

# Variables
$CSVDestination = "c:\Meetingrooms-csv"
$CSVName = "meetingrooms.csv"

# Set TLS protocol type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Folder Structure

#Creating folder for file
if (!(Test-Path $CSVDestination)) {
    write-host "Destination folder does not exist, creating"
    MD $CSVDestination -force | Out-Null
    MD $CSVDestination\Logs -force | Out-Null
}
else {
    Write-host "Destination folder exist, no need to create"            
    Write-host "Destination folder exist, testing log folder"            
    if (!(test-path $CSVDestination\Logs)) {
        Write-host "Log folder does not exist, creating"            
        MD $CSVDestination\Logs -Force | Out-Null
    }
    else {
        Write-host "Log folder exist"  
    }
}

# Get date info for logging
$datefilename = Get-Date -Format "dd-MM-yyyy_HH-mm"

# Get CSV from Storage blob
        
# SAS-URI for the CSV file deployed to the devices containing the URL/Country/Serialnr information
# Valid from/to: Valid from/to: 15/06/2022-->15/06/2028
$CSVDownloadSource = "###" # <----- The URI for your CSV file

# SAS-URI for the script deployed with scheduled task for the device to verify and check URL is correct
# Valid from/to: Valid from/to: 15/06/2022-->15/06/2028
$TaskScript = "###" # <----- The URI for your CheckKioskUrl.ps1 file
$ScriptName = "CheckKioskUrl.ps1"     

# Start logg
Start-Transcript -Path "$CSVDestination\Logs\DeploymentLog_$datefilename.txt"   

# Disable Edge auto recover feature
$EdgeRegistry1 = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Recovery"
if (!(Test-Path $edgeregistry1)) {
    new-item -Path $EdgeRegistry1 -Force
    New-ItemProperty -path $edgeregistry1 -Name Autorecovery -PropertyType DWORD -Value 2 -force
}
else {
    New-ItemProperty -path $edgeregistry1 -Name Autorecovery -PropertyType DWORD -Value 2 -Force
}

$EdgeRegistry2 = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recovery"
if (!(Test-Path $edgeregistry2)) {
    new-item -Path $EdgeRegistry2 -Force
    New-ItemProperty -path $edgeregistry2 -Name Autorecovery -PropertyType DWORD -Value 2 -Force
}
else {
    New-ItemProperty -path $edgeregistry2 -Name Autorecovery -PropertyType DWORD -Value 2 -Force
}

# Create scheduled task for device

# Downloads the PS1 script for the task
Start-BitsTransfer -Source $TaskScript -Destination "$CSVDestination\$ScriptName"

# Settings for the task
$taskname = "CheckKioskUrl"
$taskpath = "\Meetingrooms\"
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -executionpolicy unrestricted -noninteractive -file $CSVDestination\$ScriptName" -WorkingDirectory "$CSVDestination"
$Principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -Daily -At 6am

# Register the task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -TaskPath $taskpath -Description "Test for correct value of Kiosk URL for the device, will update if mismatch from CSV file" -Principal $Principal -Force
    
# Change to every hour for 1 day period     
$task = Get-ScheduledTask -TaskName $taskname -TaskPath $taskpath
$task.Triggers.Repetition.Interval = "PT1H"
$task.Triggers.Repetition.Duration = "P1D"
$task.Settings.DisallowStartIfOnBatteries = $false
$task.Settings.Compatibility = "Win8"
$task.settings.CimInstanceProperties.Item('MultipleInstances').Value = 3   # 3 corresponds to 'Stop the existing instance' source: https://stackoverflow.com/questions/59113643/stop-existing-instance-option-when-creating-windows-scheduled-task-using-powersh
$task | Set-ScheduledTask 
                
# Download CSV File
Start-BitsTransfer -Source $CSVDownloadSource -Destination "$CSVDestination\$CSVName"

# Get CSV content    
$inputFile = "$CSVDestination\$csvname"

# Get device serial
$GetDeviceSerial = Get-WmiObject Win32_BIOS | Select SerialNumber -ExpandProperty SerialNumber

$CSVrecords = Import-Csv $inputFile -Delimiter ";" -Encoding Default    
            
# Find value
$searchTerm = $GetDeviceSerial
$URLinfo = $CSVrecords | Where-Object { $_.DeviceSerial -match $searchTerm -or $_.system -match $searchTerm } | Select-Object -ExpandProperty URL

# Get kiosk regsetting
$kioskRegistrySearchPath = "HKLM:\SOFTWARE\Microsoft\Windows\AssignedAccessConfiguration\Profiles\*\AllowedApps"
$OldValueURL = "https://www.vg.no"    
$GetValuePath = Get-ChildItem -path $kioskRegistrySearchPath -Recurse | Where-Object Property -EQ Arguments | Select-Object -ExpandProperty Name
$ValuePath = $GetValuePath -replace "HKEY_LOCAL_MACHINE", "HKLM:"
$GetCurrentValue = Get-ItemProperty -Path $ValuePath -Name Arguments | Select-Object -ExpandProperty Arguments
$SetNewURLValue = "--no-first-run --kiosk $URLinfo --edge-kiosk-type=fullscreen"

# Waiting for installation to complete
while (-not (Test-Path -Path $kioskRegistrySearchPath)) {
    Start-Sleep -Seconds 5
}
 
# Change Registry Value
Try {
    Set-ItemProperty -Path $ValuePath -Name Arguments $SetNewURLValue
    IF ($? -eq $true) {
        Write-host "Set registry value success!" -ForegroundColor Green
        Write-host "URL Value for device is set to $URLinfo" -ForegroundColor Cyan

        # Add setting to verify installed url
        $RegistryInstalledPath = "HKLM:\SOFTWARE\MeetingRoomUrl"    
        $InstalledName = "Installed"
        $InstalledValue = "True"
        $InstalledURL = "InstalledURL"
        $InstalledURLValue = "$URLinfo"

        # Add registry values to verify change installed
        IF (!(Test-Path $RegistryInstalledPath)) {
            New-Item -Path $RegistryInstalledPath -Force | Out-Null
            New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledName -Value $InstalledValue -PropertyType STRING -force | Out-Null
            New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledUrl -Value $InstalledURLValue -PropertyType STRING -force | Out-Null

            # Kill Edge and restart device
            Write-Host "Closing Edge and initiating device reboot"
            # get MSedge process
            $MSedge = Get-Process MSedge -ErrorAction SilentlyContinue
            if ($MSedge) {
                # try gracefully first
                $MSedge.CloseMainWindow()
                # kill after five seconds
                Sleep 5
                if (!$MSedge.HasExited) {
                    $MSedge | Stop-Process -Force
                }
            }
            Remove-Variable MSedge
            Write-host "shutdown line 163"
            # Stop logg
            Stop-Transcript
            shutdown.exe -r -t 00                    
        }
        else {
            New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledName -Value $InstalledValue -PropertyType STRING -force | Out-Null
            New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledUrl -Value $InstalledURLValue -PropertyType STRING -force | Out-Null
            # Kill Edge and restart device
            Write-Host "Closing Edge and initiating device reboot"
            # get MSedge process
            $MSedge = Get-Process MSedge -ErrorAction SilentlyContinue
            if ($MSedge) {
                # try gracefully first
                $MSedge.CloseMainWindow()
                # kill after five seconds
                Sleep 5
                if (!$MSedge.HasExited) {
                    $MSedge | Stop-Process -Force
                }
            }
            Remove-Variable MSedge
            Write-host "shutdown line 141"
            # Stop logg
            Stop-Transcript
            shutdown.exe -r -t 00                            
        }
    }
}
Catch {
    Write-host "Set registry value failed!" -ForegroundColor yellow
    Write-host "Message: [$($_.Exception.Message)"] -ForegroundColor Red -BackgroundColor
    # Stop logg
    Stop-Transcript
}   

# Stop logg
Stop-Transcript
    
# Clears the error log from powershell before exiting
$error.clear()

# Exit
Exit 0
