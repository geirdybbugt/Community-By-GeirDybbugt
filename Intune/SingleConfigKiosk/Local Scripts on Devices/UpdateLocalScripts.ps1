<#
Update local scripts on device
Update 30.06.22
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
    
# Downloads the PS1 script for the task
Start-BitsTransfer -Source $TaskScriptCheckKioskUrl -Destination "$CSVDestination\$ScriptNameCheckKioskUrl"
# Downloads the PS1 script for the task
Start-BitsTransfer -Source $TaskScriptUpdateKioskCSV -Destination "$CSVDestination\$ScriptNameUpdateKioskCSV"
# Downloads the PS1 script for the task
Start-BitsTransfer -Source $TaskScriptUpdateLocalScripts -Destination "$CSVDestination\$ScriptNameUpdateLocalScripts"

# Clears the error log from powershell before exiting
$error.clear()