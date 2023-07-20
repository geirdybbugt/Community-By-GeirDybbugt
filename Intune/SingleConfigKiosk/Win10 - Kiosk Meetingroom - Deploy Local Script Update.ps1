<#
Update local scripts on device
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

# Get from Storage blob

# SAS-URI for the script deployed with scheduled task for the device to verify and check URL is correct
# Valid from/to: Valid from/to: 15/06/2022-->15/06/2028
$TaskScriptCheckKioskUrl = "###" # <----- The URI for your CheckKioskUrl.ps1 file
$ScriptNameCheckKioskUrl = "CheckKioskUrl.ps1"

# SAS-URI for the script deployed with scheduled task for the device to update the CSV
# Valid from/to: Valid from/to: 23/06/2022-->23/06/2028
$TaskScriptUpdateKioskCSV = "###" # <----- The URI for your UpdateKioskCSV.ps1 file
$ScriptNameUpdateKioskCSV = "UpdateKioskCSV.ps1"
    
# SAS-URI for the script deployed with scheduled task for the device to update the CSV
# Valid from/to: Valid from/to: 30/06/2022-->23/06/2028
$TaskScriptUpdateLocalScripts = "###" # <----- The URI for your UpdateLocalScripts.ps1 file
$ScriptNameUpdateLocalScripts = "UpdateLocalScripts.ps1"

# Dump files on device

#Set TLS protocol type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
# Downloads the PS1 script for the task CheckKioskUrl
Start-BitsTransfer -Source $TaskScriptCheckKioskUrl -Destination "$CSVDestination\$ScriptNameCheckKioskUrl"
# Downloads the PS1 script for the task UpdateKioskCSV
Start-BitsTransfer -Source $TaskScriptUpdateKioskCSV -Destination "$CSVDestination\$ScriptNameUpdateKioskCSV"
# Downloads the PS1 script for the task UpdateLocalScripts
Start-BitsTransfer -Source $TaskScriptUpdateLocalScripts -Destination "$CSVDestination\$ScriptNameUpdateLocalScripts"

# Settings for the task
$taskname = "UpdateLocalScripts"
$taskpath = "\Meetingrooms\"
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -executionpolicy unrestricted -noninteractive -file $CSVDestination\$ScriptNameUpdateLocalScripts" -WorkingDirectory "$CSVDestination"
$Principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -Daily -At 4am

# Register the task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -TaskPath $taskpath -Description "Update local scripts" -Principal $Principal -Force    

# Adjust some settings for the task
$task = Get-ScheduledTask -TaskName $taskname -TaskPath $taskpath
$task.Settings.DisallowStartIfOnBatteries = $false
$task.Settings.Compatibility = "Win8"
$task.settings.CimInstanceProperties.Item('MultipleInstances').Value = 3   # 3 corresponds to 'Stop the existing instance' source: https://stackoverflow.com/questions/59113643/stop-existing-instance-option-when-creating-windows-scheduled-task-using-powersh
$task | Set-ScheduledTask

# Clears the error log from powershell before exiting
$error.clear()

# Exit
Exit 0
