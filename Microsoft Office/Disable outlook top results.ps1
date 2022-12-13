## Disable outlook top results
# Geir Dybbugt - Serit møre - 02.09.21

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


# location for registry setting - location 1 
    $valuelocation = "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Settings\Data"
    $valuename = "global_Search_SearchTopResults"
    
# save the existing value
    $oldvalue = Get-ItemProperty $valuelocation -Name $valuename

    # create replacement value
        $newValue = $oldvalue.global_Search_SearchTopResults -replace '"value":"true"', '"value":"false"'
    # change the value
        Set-ItemProperty $valuelocation $valuename -value $newValue 
    # verify the change
        $verifychange = Get-ItemProperty $valuelocation -Name $valuename
        $verifychange.global_Search_SearchTopResults

# location for registry setting - location 2
    $valuelocation = "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Search"
    $valuename = "SearchTopResults"
    $value = "0"

    # Change the value
        New-ItemProperty -Path $valuelocation -Name $valuename -Value $value -PropertyType DWORD -Force