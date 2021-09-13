####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
#### Script to change the default calendar permissions across the internal organization. 
#### There is currently no way to do this in the 365 admin portals for the internal organization.
#### 10/09/2021
####------------------------------------------------------------------------####


# The interorg-level permissions are set through the 'Default' user context; 
# https://docs.microsoft.com/en-us/powershell/module/exchange/set-mailboxfolderpermission?view=exchange-ps

# Connect to exchange online. 
    Connect-ExchangeOnline

# Logging
    # Get date info for logging
        $datefilename = Get-Date -Format "dd-MM-yyyy_HH-mm"

    # Start logging
        Start-Transcript -Path "C:\transcripts\365-MailboxPermission_transcript-$datefilename.txt"

# Variables
    $ExcludedAlias = "*Alias To Exclude*" # edit if needed, if not needed, remove it from the 'where-object' part on line 28 and line 32
    $ExcludedName = "*Name To Exclude*" # edit if needed, if not needed, remove it from the 'where-object' part on line 28 and line 32
    $IncludeSharedMailboxes = $false # set to false to process user and not include shared mailboxes - set to true to only process shared mailboxes.
    $DefaultPermission ="LimitedDetails" # Default internal org permissions - see info in link at the top of script for MS article with all the various permissions.
    $EditorPermission = "Editor" # see info in link at the top of script for MS article with all the various permissions.

# Users with edit rights - uses the display name of the users that will be granted edit permissions
    $Editors = @(
        #"User Display Name"
        )

# Display targeted mailboxes
    Write-Host "The script will target the following users/mailboxes" -ForegroundColor Yellow
    get-mailbox | Where-Object {$_.IsShared -eq $IncludeSharedMailboxes -and $_.alias -notlike "${ExcludedAlias}" -and $_.Name -notlike "${ExcludedName}"} | Select-Object Name, Alias | Format-Table -AutoSize
    Write-Host ""

# Get targeted mailboxes alias
    $MailboxAlias = get-mailbox | Where-Object {$_.IsShared -eq $IncludeSharedMailboxes -and $_.alias -notlike "${ExcludedAlias}" -and $_.Name -notlike "${ExcludedName}"} | Select-Object -ExpandProperty alias

# Change default permissions
    foreach ($mailbox in $MailboxAlias)
    {
        write-host "############ Processing mailbox '$mailbox' ############"
        # Get default calendar name
            $GetCalendarName = Get-MailboxFolderStatistics -Identity $Mailbox -FolderScope Calendar |  Where-Object {$_.foldertype -eq "Calendar"} | Select-Object -ExpandProperty Identity
            $CalendarName = $GetCalendarName -replace "$mailbox", "${mailbox}:"
            write-host "Calendar name for the mailbox named '$mailbox' is '$CalendarName'" -ForegroundColor Green
        
        # Set default calendar default permissions
            # Show current default permissions
                Write-host "current default permissions.:" -ForegroundColor yellow
                get-MailboxFolderPermission -Identity $CalendarName -User Default
                write-host ""

            # Show new default permissions
                Write-host "new default permissions.:" -ForegroundColor red
                Set-MailboxFolderPermission -Identity $CalendarName -User Default -AccessRights $DefaultPermission
                get-MailboxFolderPermission -Identity $CalendarName -User Default
                write-host ""
                write-host ""
        }

        # Give edit permissions to selected users for the calendar
            write-host "Adding editor permission" -ForegroundColor Cyan
            foreach ($Editor in $Editors)
            {
                $TestForExistingPermission = Get-MailboxFolderPermission -Identity "$CalendarName" | Select-Object -ExpandProperty user | Select-Object -ExpandProperty displayname
                if ( $TestForExistingPermission -contains "$Editor") {
                    write-host "Editor already has existing permission - changing if needed" -ForegroundColor Yellow
                    Set-MailboxFolderPermission -Identity $CalendarName -User $editor -AccessRights $EditorPermission
                    write-host "Permission changed for user '$editor' on calendar '$Calendarname'" -ForegroundColor Red
                    get-MailboxFolderPermission -Identity $CalendarName -User $Editor
                    write-host ""
                    write-host ""
                    } else {
                    write-host "Editor does not exist - adding permission" -ForegroundColor Yellow
                    add-MailboxFolderPermission -Identity $CalendarName -User $Editor -AccessRights $EditorPermission
                    write-host "Permission added for user '$editor' on calendar '$Calendarname'" -ForegroundColor Red
                    get-MailboxFolderPermission -Identity $CalendarName -User $Editor
                    write-host ""
                    write-host ""
                    }
            }
    }

# Stop logging
    Stop-Transcript
    
# Disconnect from exchange online. 
    disconnect-ExchangeOnline

# Cleanup 
    Remove-Variable ExcludedAlias
    Remove-Variable ExcludedName
    Remove-Variable IncludeSharedMailboxes
    Remove-Variable DefaultPermission
    Remove-Variable EditorPermission
    Remove-Variable Editors
    Remove-Variable Editor
    Remove-Variable MailboxAlias
    Remove-Variable Mailbox
    Remove-Variable GetCalendarName
    Remove-Variable Calendarname
    Remove-Variable TestForExistingPermission