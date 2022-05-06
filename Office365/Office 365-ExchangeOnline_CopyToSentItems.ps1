<# setting to save sent items in the mailbox sent items folder
When users are using the "send on behalf of or send as functions.

Modified: 06.05.2022 - Geir Dybbugt
#>

# Info: https://docs.microsoft.com/en-us/exchange/troubleshoot/user-and-shared-mailboxes/sent-mail-is-not-saved

# Connect to exchange online
    Connect-ExchangeOnline

# Using Exchange PowerShell, for emails Sent As the shared mailbox
    set-mailbox email@domain.com -MessageCopyForSentAsEnabled $True

# Using Exchange PowerShell, for emails Sent On Behalf of the shared mailbox,
    set-mailbox email@domain.com -MessageCopyForSendOnBehalfEnabled $True

# Check status
    get-mailbox -Identity email@domain.com | Select-Object DisplayName,MessageCopyForSendOnBehalfEnabled, MessageCopyForSentAsEnabled | ft -AutoSize
