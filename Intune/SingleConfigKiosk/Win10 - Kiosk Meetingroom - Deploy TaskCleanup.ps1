<#
Update tasks on device
update: 13:30 01.03.2023
#>

# change scheduled tasks

# remove current tasks
$taskExists = Get-ScheduledTask -TaskPath "\" | Where-Object { ($_.TaskName -eq "UpdateLocalScripts" -or $_.TaskName -eq "UpdateKioskCSV" -or $_.TaskName -eq "CheckKioskUrl" ) }

ForEach ($Task in $taskExists) {
    Unregister-ScheduledTask -TaskName $Task.TaskName -TaskPath $task.TaskPath -Confirm:$false
}

# Root location
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

# UpdateLocalScripts
# Settings for the task
$ScriptNameUpdateLocalScripts = "UpdateLocalScripts.ps1"
$taskname = "UpdateLocalScripts"
$taskpath = "\Meetingrooms\"
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -executionpolicy unrestricted -noninteractive -file $CSVDestination\$ScriptNameUpdateLocalScripts" -WorkingDirectory "$CSVDestination"
$Principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -Daily -At 4am

# Register the task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -TaskPath $taskpath -Description "Update local scripts" -Principal $Principal -Force
    
# Change to every hour for 1 day period     
$task = Get-ScheduledTask -TaskName $taskname -TaskPath $taskpath
$task.Triggers.Repetition.Interval = "PT1H"
$task.Triggers.Repetition.Duration = "P1D"
$task.Settings.DisallowStartIfOnBatteries = $false
$task.Settings.Compatibility = "Win8"
$task.settings.CimInstanceProperties.Item('MultipleInstances').Value = 3   # 3 corresponds to 'Stop the existing instance' source: https://stackoverflow.com/questions/59113643/stop-existing-instance-option-when-creating-windows-scheduled-task-using-powersh
$task | Set-ScheduledTask 
        
# UpdateKioskCSV
# Settings for the task
$ScriptName = "UpdateKioskCSV.ps1"
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


# CheckKioskUrl
# Settings for the task
$ScriptName = "CheckKioskUrl.ps1" 
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
