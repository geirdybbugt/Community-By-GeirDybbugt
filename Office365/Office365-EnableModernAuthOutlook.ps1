# Enable or disable modern authentication for Outlook in Exchange Online
        # Source https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/enable-or-disable-modern-authentication-in-exchange-online

# Connect to Exchange Online
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session -DisableNameChecking

# Enable modern auth
    Set-OrganizationConfig -OAuth2ClientProfileEnabled $true

# Disable modern auth
    #Set-OrganizationConfig -OAuth2ClientProfileEnabled $false

# Verify status
    Get-OrganizationConfig | Format-Table Name,OAuth* -Auto

# End session
    Remove-PSSession $Session