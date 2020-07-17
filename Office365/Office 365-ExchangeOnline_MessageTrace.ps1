####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
#### Simple command to run a message trace on Exchange-Online and export to a csv file for further work. 
####------------------------------------------------------------------------####

# Install updated module for connection to Exchange Online with modern auth support
Install-Module -Name ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline

# Trace Email within time period
Get-MessageTrace -SenderAddress epost@domene.com -StartDate MM/DD/YYYY -EndDate MM/DD/YYYY  | Select-object senderaddress,recipientaddress,subject,status,received| Export-Csv C:\temp\messagetrace_report.csv

# End powershell session
Disconnect-ExchangeOnline