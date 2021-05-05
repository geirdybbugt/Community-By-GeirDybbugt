####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
#### Uninstalls native receiver
#### modified:: 5/5/2021
####------------------------------------------------------------------------####
<#
.SYNOPSIS
    Removes native Citrix Receiver.
    Intended to run via Intune.
#>

#Get folder name for version
    $uninstallname = Get-ChildItem "C:\ProgramData\Citrix" | where name -like "Citrix Workspace*" | Select-Object -ExpandProperty fullname

#start uninstaller
    $fullpath = "$uninstallname" + "\" + "TrolleyExpress.exe"
    & $fullpath  /uninstall /cleanup /silent 

# Clears the error log from powershell before exiting
    $error.clear()