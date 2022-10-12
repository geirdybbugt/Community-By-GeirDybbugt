# Script to set the programatic security settings of Outlook via intune
# updated 12.10.2022 - Geir Dybbugt - https://dybbugt.no

# Registry paths
    $hkcupolicy = "HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Security"
    $hkcu = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Security"
    $hklm = "HKLM:\Software\Policies\Microsoft\Office\16.0\Outlook\Security"

# Create Array list for all resources to be created
    $items2 = @(
    "promptoomaddressbookaccess"
    "promptoomformulaaccess"
    "promptoomsaveas"
    "promptoomaddressinformationaccess"
    "promptoommeetingtaskrequestresponse"
    "promptoomsend"
    "promptsimplemapiopenmessage"
    "promptsimplemapinameresolve"
    "promptsimplemapisend"
    )

    $AdminSecurityMode = "AdminSecurityMode"
    $CheckAdminSettings = "CheckAdminSettings"
    
# add values to registry
# For the policy location in registry
    if(!(Test-Path $hkcupolicy)){
        Write-host "missing the path $hkcupolicy in registry, it will be created" -ForegroundColor Cyan
        New-Item -Path $hkcupolicy -Force
        foreach($item in $items2){
        New-ItemProperty -Path $hkcupolicy -Name $item -Value 2 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcupolicy -Name $AdminSecurityMode -Value 3 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcupolicy -Name $CheckAdminSettings -Value 1 -PropertyType DWORD -Force | Out-Null
        }
    } else {
        Write-host "Path $hkcupolicy in registry exists" -ForegroundColor green
        foreach($item in $items2){
        New-ItemProperty -Path $hkcupolicy -Name $item -Value 2 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcupolicy -Name $AdminSecurityMode -Value 3 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcupolicy -Name $CheckAdminSettings -Value 1 -PropertyType DWORD -Force | Out-Null
        }
    }

# For the normal location in registry
    if(!(Test-Path $hkcu)){
        Write-host "missing the path $hkcu in registry, it will be created" -ForegroundColor Cyan
        New-Item -Path $hkcu -Force
        foreach($item in $items2){
        New-ItemProperty -Path $hkcu -Name $item -Value 2 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcu -Name $AdminSecurityMode -Value 3 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcu -Name $CheckAdminSettings -Value 1 -PropertyType DWORD -Force | Out-Null
        }
    } else {
        Write-host "Path $hkcu in registry exists" -ForegroundColor green
        foreach($item in $items2){
        New-ItemProperty -Path $hkcu -Name $item -Value 2 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcu -Name $AdminSecurityMode -Value 3 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hkcu -Name $CheckAdminSettings -Value 1 -PropertyType DWORD -Force | Out-Null
        }
    }

<# For the hklm location in registry
    if(!(Test-Path $hklm)){
        Write-host "missing the path $hklm in registry, it will be created" -ForegroundColor Cyan
        New-Item -Path $hklm -Force
        foreach($item in $items2){
        New-ItemProperty -Path $hklm -Name $item -Value 2 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hklm -Name $AdminSecurityMode -Value 3 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hklm -Name $CheckAdminSettings -Value 1 -PropertyType DWORD -Force | Out-Null
        }
    } else {
        Write-host "Path $hklm in registry exists" -ForegroundColor green
        foreach($item in $items2){
        New-ItemProperty -Path $hklm -Name $item -Value 2 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hklm -Name $AdminSecurityMode -Value 3 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $hklm -Name $CheckAdminSettings -Value 1 -PropertyType DWORD -Force | Out-Null
        }
    }
#>

exit 0