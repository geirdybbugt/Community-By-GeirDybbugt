##Edit mailbox regional settings

#Connect to Exchange online
Connect-ExchangeOnline

#List all mailboxes
get-mailbox

#Check regional configuration for wanted mailbox
get-MailboxRegionalConfiguration -Identity somemailboxname

 
#Set regional configuration for wanted mailbox
Set-MailboxRegionalConfiguration -Identity somemailboxname -TimeZone "W. Europe Standard Time" -DateFormat "dd.MM.yyyy" -TimeFormat "HH:mm" -Confirm:$true -Language nb-NO


#Disconnect to Exchange online
disconnect-ExchangeOnline