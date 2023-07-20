<#
Script to set device url for kiosk pr device based on serial number
The CSV file is located in Azure Storage blob
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

# Get date info for logging
$datefilename = Get-Date -Format "dd-MM-yyyy_HH-mm"

# Variables
$CSVDestination = "c:\Meetingrooms-csv"
$CSVName = "meetingrooms.csv"

#Folder Structure

#Creating folder for file
if (!(Test-Path $CSVDestination)) {
    write-host "Destination folder does not exist, creating" -ForegroundColor red
    MD $CSVDestination -force | Out-Null
}
else {
    Write-host "Destination folder exist, no need to create" -ForegroundColor Cyan
}

# Start logg
Start-Transcript -Path "$CSVDestination\Logs\MeetingDisplayLog_$datefilename.txt"

#Disable Edge auto recover feature
$EdgeRegistry1 = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Recovery"
if (!(Test-Path $edgeregistry1)) {
    new-item -Path $EdgeRegistry1 -Force
    New-ItemProperty -path $edgeregistry1 -Name Autorecovery -PropertyType DWORD -Value 2 -Force | Out-Null
}
else {
    New-ItemProperty -path $edgeregistry1 -Name Autorecovery -PropertyType DWORD -Value 2 -Force | Out-Null
}

$EdgeRegistry2 = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recovery"
if (!(Test-Path $edgeregistry2)) {
    new-item -Path $EdgeRegistry2 -Force
    New-ItemProperty -path $edgeregistry2 -Name Autorecovery -PropertyType DWORD -Value 2 -force | Out-Null
}
else {
    New-ItemProperty -path $edgeregistry2 -Name Autorecovery -PropertyType DWORD -Value 2 -Force | Out-Null
}

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
$GetValuePath = Get-ChildItem -path $kioskRegistrySearchPath -Recurse | Where-Object Property -EQ Arguments | Select-Object -ExpandProperty Name
$ValuePath = $GetValuePath -replace "HKEY_LOCAL_MACHINE", "HKLM:"
$GetCurrentValue = Get-ItemProperty -Path $ValuePath -Name Arguments | Select-Object -ExpandProperty Arguments

# Test for matching values
Try {
    if ($GetCurrentValue -notmatch $URLinfo) {
        write-host "Confgured URL mismatch from CSV, will change url to '$URLinfo'" -ForegroundColor Red

        # Get CSV from Storage blob
        # Source file location
        $CSVDownloadSource = "###" # <----- The URI for your meetingrooms.csv file

        # Set TLS protocol type
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Downloads the file from source
        Start-BitsTransfer -Source $CSVDownloadSource -Destination "$CSVDestination\$CSVName"

        # Get device serial
        $GetDeviceSerial = Get-WmiObject Win32_BIOS | Select SerialNumber -ExpandProperty SerialNumber
        $CSVrecords = Import-Csv $inputFile -Delimiter ";" -Encoding Default
            
        # Find value
        $searchTerm = $GetDeviceSerial
        $URLinfo = $CSVrecords | Where-Object { $_.DeviceSerial -match $searchTerm -or $_.system -match $searchTerm } | Select-Object -ExpandProperty URL

        # Add setting to verify installed url
        $RegistryInstalledPath = "HKLM:\SOFTWARE\MeetingRoomUrl"    
        $InstalledName = "Installed"
        $InstalledValue = "True"
        $InstalledURL = "InstalledURL"
        $InstalledURLValue = "$URLinfo"

        # Change the value in registry
        Set-ItemProperty -Path $ValuePath -Name Arguments "--no-first-run --kiosk $URLinfo --edge-kiosk-type=fullscreen" -Force
        IF ($? -eq $true) {
            Write-host "Set registry value success!" -ForegroundColor Green
            Write-host "URL Value for device is changed to $URLinfo" -ForegroundColor Cyan
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
            # Add registry values to verify change installed
            IF (!(Test-Path $RegistryInstalledPath)) {
                write-host "Registry installation info missing, will add information"
                New-Item -Path $RegistryInstalledPath -Force | Out-Null
                New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledName -Value $InstalledValue -PropertyType STRING -force | Out-Null
                New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledUrl -Value $InstalledURLValue -PropertyType STRING -force | Out-Null
            }
            else {
                write-host "Registry installation info exists, will update information"
                New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledName -Value $InstalledValue -PropertyType STRING -force | Out-Null
                New-ItemProperty -Path $RegistryInstalledPath -Name $InstalledUrl -Value $InstalledURLValue -PropertyType STRING -force | Out-Null
            }
            Write-host "shutdown on line 132"
            Shutdown.exe -r -t 00
        }
        else {
            Write-host "Set registry value failed on line 79" -ForegroundColor Red
            Write-host "Value is still set to: '$GetCurrentValue'"
        }
    }
    else {
        write-host "URL value is correct" -ForegroundColor Green
        Write-host "URL Value for device is $URLinfo" -ForegroundColor Cyan
    }
}
Catch {
    Write-host "Set registry value failed!" -ForegroundColor yellow
    Write-host "Message: [$($_.Exception.Message)"] -ForegroundColor Red
}  

# Stop logging
Stop-Transcript 

# Clear error log before exits
$error.clear()