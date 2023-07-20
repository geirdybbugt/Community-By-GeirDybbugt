<#
Script add a task to check the device url
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

# SAS-URI for the script deployed with scheduled task for the device to verify and check URL is correct
# Valid from/to: Valid from/to: 15/06/2022-->15/06/2028
$TaskScript = "###" # <----- The URI for your CheckKioskUrl.ps1 file
$ScriptName = "CheckKioskUrl.ps1"     

# Create scheduled task for device

# Set TLS protocol type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

# Clears the error log from powershell before exiting
$error.clear()

# Exit
Exit 0
