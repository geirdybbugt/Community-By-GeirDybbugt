<#
Script add a CSV updating task on kiosk devices
The Script is located in Azure storage blob
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

#Folder Structure

#Creating folder for file
if (!(Test-Path $CSVDestination)) {
    write-host "Destination folder does not exist, creating"
    MD $CSVDestination -force | Out-Null
    MD "$CSVDestination\Logs" -force | Out-Null
}
else {
    Write-host "Destination folder exist, no need to create"            
}

# SAS-URI for the script deployed with scheduled task for the device to update the CSV
# Valid from/to: Valid from/to: 150223-1502
$TaskScript = "#####" # <--------- set your URI for the script in azure storage here.
$ScriptName = "UpdateKioskCSV.ps1"

# Create scheduled task for device

# Set TLS protocol type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Downloads the PS1 script for the task
Start-BitsTransfer -Source $TaskScript -Destination "$CSVDestination\$ScriptName"

# Settings for the task
$taskname = "UpdateKioskCSV"
$taskpath = "\Meetingrooms\"
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -executionpolicy unrestricted -noninteractive -file $CSVDestination\$ScriptName" -WorkingDirectory "$CSVDestination"
$Principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -Daily -At 5am

# Register the task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -TaskPath $taskpath -Description "Update the local CSV file on the device" -Principal $Principal -Force 
    
# Change to every hour for 1 day period     
$task = Get-ScheduledTask -TaskName $taskname -TaskPath $taskpath
$task.Triggers.Repetition.Interval = "PT1H"
$task.Triggers.Repetition.Duration = "P1D"
$task.Settings.DisallowStartIfOnBatteries = $false
$task.Settings.Compatibility = "Win8"
$task.settings.CimInstanceProperties.Item('MultipleInstances').Value = 3   # 3 corresponds to 'Stop the existing instance' source: https://stackoverflow.com/questions/59113643/stop-existing-instance-option-when-creating-windows-scheduled-task-using-powersh
$task | Set-ScheduledTask 

# Clears the error log from powershell before exiting
$error.clear()

# Exit
Exit 0
