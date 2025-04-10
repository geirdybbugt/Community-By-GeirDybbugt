
# Script to collect information on registered passkeys across tenant. 
# will give you results in a report for later, and a file with the unique aaguids of 
# keys used in the tenant in case you want to limit what keys are allowed to use
# while avoiding disruption before doring the limitations

# set powershell to use tls 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# Location to save exported files
$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

# Get running date
$date = Get-Date -Format "dd.MM.yyyy"

# Connect to MS Graph
Connect-MgGraph -Scopes UserAuthenticationMethod.Read.All, AuditLog.Read.All
$Report = @()

# Get information on all users with registered passkeys/fido
$PasskeyUsers = Invoke-MgGraphRequest -Method GET `
    -Uri "beta/reports/authenticationMethods/userRegistrationDetails?`$filter=methodsRegistered/any(i:i eq 'passKeyDeviceBound') OR methodsRegistered/any(i:i eq 'passKeyDeviceBoundAuthenticator')" `
    -OutputType PSObject | Select -expand Value

# Create object  containing information for export
Foreach ($user in $PasskeyUsers) {
    $passkey = Invoke-MgGraphRequest -Method GET -Uri "beta/users/$($user.id)/authentication/fido2Methods" -OutputType PSObject | Select -Expand Value
    $obj = [PSCustomObject][ordered]@{
        "User"         = $user.UserPrincipalName
        "Passkey"      = $passkey.displayName -join ','
        "Model"        = $passkey.model -join ','
        "aaGuid"       = $passkey.aaGuid -join ','
        "uniqueaaGuid" = $passkey.aaGuid
        "Date created" = $passkey.createdDateTime -join ','
    }
    $Report += $obj
}

# Show results on screen
$Report | Out-GridView

# Export to CSV file for reporting
$Report | Export-csv -path $DesktopPath\UserPasskeyList-$date.csv -NoTypeInformation -Encoding UTF8

# Export a txt file with only the unique AAGUID of all registered keys in tenant
$report.uniqueaaGuid | select -Unique | Out-File -FilePath $DesktopPath\UniqueUserPasskeys-AAGUIDs.txt -Encoding utf8

# Disconnect 
Disconnect-Graph