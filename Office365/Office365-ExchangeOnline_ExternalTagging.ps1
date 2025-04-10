# Enable External tagging for outlook

Connect-ExchangeOnline

#https://www.codetwo.com/admins-blog/mailtips-in-office-365/
Get-OrganizationConfig | select *mailtips*
Set-OrganizationConfig -MailTipsExternalRecipientsTipsEnabled $true

#https://learn.microsoft.com/en-us/powershell/module/exchange/set-externalinoutlook?view=exchange-ps
Set-ExternalInOutlook -Enabled $true

Disconnect-ExchangeOnline