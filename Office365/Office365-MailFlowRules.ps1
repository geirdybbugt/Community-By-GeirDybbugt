## Add some mail flow rules to 365

# Connect to Exchange online
    Connect-ExchangeOnline

# Choose EN/NO caution bar - Shows a yellow infobar at start of an email if it is originating from outside the organization
    function Show-Menu
{
     param (
           [string]$Title = 'Choose external email warning language'
     )
     cls
     Write-Host "================ $Title ================"
    
     Write-Host "1: Press '1' for English."
     Write-Host "2: Press '2' for Norwegian."
     Write-Host "Q: Press 'Q' to cancel."     
}

do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
                # English disclaimer - Shows a yellow infobar at start of an email if it is originating from outside the organization
                    New-TransportRule -Name "External senders warning - EN" -FromScope NotInOrganization -SentToScope InOrganization -ApplyHtmlDisclaimerLocation prepend -ApplyHtmlDisclaimerFallbackAction wrap -ApplyHtmlDisclaimerText '<p><div style="background-color:#FFEB9C; width:100%; border-style: solid; border-color:#9C6500; border-width:1pt; padding:2pt; font-size:10pt; line-height:12pt; font-family:Calibri; color:Black; text-align: left;"><span style="color:#9C6500"; font-weight:bold;>CAUTION:</span> This email originated from outside of the organization. Do not click links or open attachments unless you recognize the sender and know the content is safe.</div><br></p>'  -SetAuditSeverity Medium -Comments "Shows a yellow infobar at start of an email if it is originationg from outside the organization" -Enabled $false
           } '2' {
                cls
                # Norwegian disclaimer - Shows a yellow infobar at start of an email if it is originating from outside the organization
                    New-TransportRule -Name "External senders warning - NO" -FromScope NotInOrganization -SentToScope InOrganization -ApplyHtmlDisclaimerLocation prepend -ApplyHtmlDisclaimerFallbackAction wrap -ApplyHtmlDisclaimerText '<p><div style="background-color:#FFEB9C; width:100%; border-style: solid; border-color:#9C6500; border-width:1pt; padding:2pt; font-size:10pt; line-height:12pt; font-family:Calibri; color:Black; text-align: left;"><span style="color:#9C6500"; font-weight:bold;>[ADVARSEL]:</span> Denne e-posten kommer fra en ekstern avsender. Ikke klikk på lenker eller åpne vedlegg om du er usikker på avsenderen.</div><br></p>' -SetAuditSeverity Medium -Comments "Shows a yellow infobar at start of an email if it is originationg from outside the organization" -ExceptIfSubjectOrBodyContainsWords "Denne e-posten kommer fra en ekstern avsender. Ikke" -Enabled $true
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')


# English disclaimer - Appends a disclaimer on outgoing emails
    New-TransportRule -Name "External recepients disclaimer - EN" -FromScope InOrganization -SentToScope NotInOrganization -ApplyHtmlDisclaimerLocation append -ApplyHtmlDisclaimerFallbackAction wrap -ApplyHtmlDisclaimerText '<br/><br/><br/> IMPORTANT NOTICE: This e-mail message is intended to be received only by persons entitled to receive the information it may contain. E-mail messages may contain information that is confidential and legally privileged. Please do not read, copy, forward, or store this message unless you are an intended recipient of it. If you have received this message in error, please forward it to the sender and delete it completely from your computer system.'  -Comments "Appends a disclaimer on outgoing emails to inform about confidentiality, and intended recepients" -Mode Enforce -ExceptIfSubjectOrBodyContainsWords "IMPORTANT NOTICE: This e-mail message is intended to be received only by persons"  -Enabled $true

# Block auto-forward to external recipients
    New-TransportRule -Name "Block auto-forward to external recipients" -FromScope InOrganization -SentToScope NotInOrganization -MessageTypeMatches AutoForward -RejectMessageReasonText "Client Forwarding Rules To External Domains Are Not Permitted." -comments "Blocks auto-forward to receipients outside the origanizations with rejection message" -Enabled $true

#  Block Executable Content MS Standard
    New-TransportRule -Name "Block Executable Content MS Standard" -AttachmentHasExecutableContent $true -SenderAddressLocation HeaderOrEnvelope -SetAuditSeverity Low -RejectMessageReasonText "Sorry your mail was blocked because it contained executable content" -RejectMessageEnhancedStatusCode 5.7.1 -StopRuleProcessing $true -comments "Blocks the message if it includes an attachment with executable content" -Enabled $true

#  Block Attachements by type
    New-TransportRule -Name "Block Attachements by type" -AttachmentExtensionMatchesWords "vbs,rar,scr,dll,exe,obj,vxd,os2,w16,dos,com,pic,scr,cmd,bat" -SenderAddressLocation HeaderOrEnvelope -RejectMessageReasonText "Sorry your mail was blocked because it contained attachment types with executable content." -SetAuditSeverity Low -StopRuleProcessing $true -comments "Blocks the message if it includes an attachment with executable content defined by file extension" -Enabled $true

# Disconnect to Exchange online
    disconnect-ExchangeOnline