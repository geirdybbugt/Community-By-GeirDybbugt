<#

Collection to quickly create a Microsoft Bookings calendar with some test resources to play around with. 
Go through the script to modify as needed. Replace the email addresses in the arrays to those you want to use.

This will: 
- Limit who can create Microsoft Bookings Calendars by disabling this in the default policy, and creating a dedicated policy for this
    - Policy will be named "BookingsCreatorsPolicy"
- Create a Bookings Calendar
    - Will add the user logged inn to the ExchangeOnline powershell session as the owner of the Bookings calendar.
- Add users to the calendar as SuperUsers
- Create some demo shared mailboxes for use agaings bookings to play around with
    - Will add delegates to the mailboxes, without automapping to prevent automatic listing in users Outlook
    - Will create these as room due to calendar view discrepencies between equipment vs rooms
    - will create a roomlist and add the mailboxes so you can easily add them to your calendar view should you prefer this
    - Will set Time and regional settings for the mailboxes
    - Will change default calendar premissions to limited details for the mailboxes
    - Will set the default smtp address for the mailboxes to use the default domain for the tenant

#>


# Collect existing variables before session - # Cleanup Variables part 1
$existingVariables = Get-Variable
try {

    ## Script start here

    # Executionpolicy
    Set-ExecutionPolicy -ExecutionPolicy Bypass

    # Connect Exchange online
    Connect-ExchangeOnline

    # Change some defaults for Microsoft Bookings - all users can create calendars and enable resource booking to staff etc regardless of 365 role 
    # This section disables this as default, and creates a dedicated policy that is assigned to those allowed to create MS Bookings calendars.

    # Show existing booking calendars policy
    get-owamailboxpolicy | Select-Object Name, BookingsMailboxCreationEnabled

    # Show existing booking calendars policy - create if missing
    $BookingsCreatorsPolicyName = "BookingsCreatorsPolicy"

    $testDefaultPolicy = get-OwaMailboxPolicy "OwaMailboxPolicy-Default" | Select-Object name, BookingsMailboxCreationEnabled 
    if ($testDefaultPolicy.BookingsMailboxCreationEnabled -eq $false) {
        write-host "Bookings is not enabled in the default mailbox policy - this is the recommended setting" -ForegroundColor Green
    }
    else { 
        write-host "Bookings is  enabled in the default mailbox policy - this is NOT recommended setting" -ForegroundColor Red
        write-host "Recommend to disable this in the default policy and create a seperate policy to control who will be able to manage Microsoft Bookings calendars" -ForegroundColor Yellow
        $title = 'Confirm'
        $question = 'Do you want to continue with the suggested action?' 
        $choices = '&Yes', '&No'
        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
        if ($decision -eq 0) {
            Write-Host 'You chose to continue, will  disable bookings in the default policy, and create a dedicated policy for managing Microsoft Bookings.' -ForegroundColor Cyan
            Write-Host ""
            Write-host "Creating a dedicated policy for Microsoft Bookings management, named '$BookingsCreatorsPolicyName'" -ForegroundColor Yellow
            New-OwaMailboxPolicy -Name "$BookingsCreatorsPolicyName"
            if ($?) {
                Write-host "Policy '$BookingsCreatorsPolicyName' created successfully!"  -ForegroundColor Green
            }
            else {
                Write-host "Failed to create policy '$BookingsCreatorsPolicyName'!"  -ForegroundColor Red
            }
            Write-Host ""
            Write-host "Disabling Bookings in the default policy" -ForegroundColor Yellow
            Set-OwaMailboxPolicy "OwaMailboxPolicy-Default" -BookingsMailboxCreationEnabled:$false
            if ($?) {
                Write-host "Successfully disabled bookings in the default policy!"  -ForegroundColor Green
            }
            else {
                Write-host "Failed to disable bookings in the default policy!"  -ForegroundColor red
            }
        }
        else {
            Write-Host 'Your choice is No, this will continue the process by using the default mailbox policy' -ForegroundColor Yellow
            write-host  "Setting the variable for '$BookingsCreatorsPolicyName' to the default policy" -ForegroundColor Yellow
            $BookingsCreatorsPolicyName = "OwaMailboxPolicy-Default"
            if ($?) {
                Write-Host "Policy name set to '$BookingsCreatorsPolicyName'" -ForegroundColor Cyan            
            }
            else {
                Write-Host "Failed to set policy name set to '$BookingsCreatorsPolicyName'" -ForegroundColor Cyan            
            }
        }
    }

    # Check who is allowed/assigned the policy to create Bookings callendar(s)
    Get-CASMailbox | Where-Object { $_.OwaMailboxPolicy -eq "BookingsCreatorsPolicy" } | Select-Object Identity, DisplayName, PrimarySmtpAddress, OwaMailboxPolicy | Format-Table -AutoSize

    # Add someone to the new Limited Bookings policy
    $BookingsCreatorsPolicyMembers = @(
        "someone@domain.com"
        "someone@domain.com"
        "someone@domain.com"
    )

    # Add members to the policy
    foreach ($member in $BookingsCreatorsPolicyMembers) {
        Set-CASMailbox -Identity $member -OwaMailboxPolicy "BookingsCreatorsPolicy"
        if ($?) {
            write-host "Succesfully added '$member' to the 'BookingCreatorsPolicy'" -ForegroundColor Green
        }
        else {
            write-host "failed to add '$member' to the 'BookingCreatorsPolicy'" -ForegroundColor red
        }
    }        

    # List mailboxes
    Get-Mailbox | Select-Object name, RecipientTypeDetails

    # List bookings enabled mailboxes - to show already existing Bookings Enabled mailboxes in the tenant
    Get-Mailbox -RecipientTypeDetails SchedulingMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object Identity, User, AccessRights, IsInherited, deny | Where-Object { ($_.user -like '*@*') } | Format-Table -AutoSize

    # Create a Microsoft Booking Calendar Service
    $PrimaryDomain = Get-AcceptedDomain | Where-Object default -eq True | Select-Object -ExpandProperty DomainName
    $BookingServiceName = "Demo Bookings Calendar1"
    $Name = $BookingServiceName
    $DisplayName = $BookingServiceName
    $Alias = $BookingServiceName -replace " ", "."
    $PrimarySmtpAddress = "$alias@$PrimaryDomain"
    $Owner = Get-ConnectionInformation | Select-Object -ExpandProperty UserPrincipalName -First 1

    $params = @{
        BookingServiceName = $BookingServiceName
        Name               = $Name
        DisplayName        = $DisplayName
        Alias              = $Alias
        PrimarySmtpAddress = $PrimarySmtpAddress
        Owner              = $Owner
    }

    New-SchedulingMailbox @params
    if ($?) {
        write-host "Creation of scheduling mailbox named '$BookingServiceName' was succesfull" -ForegroundColor Green
    }
    else {
        write-host "Creation of scheduling mailbox named '$BookingServiceName' failed" -ForegroundColor red
    }

    Remove-Variable params

    $CreatedBookingsCalendarIdentity = 
    Get-Mailbox -RecipientTypeDetails SchedulingMailbox -ResultSize:Unlimited |`
        Select-Object Identity, PrimarySmtpAddress |`
        Where-Object { ($_.identity -like "$BookingServiceName*") } |`
        Select-Object -ExpandProperty PrimarySmtpAddress 

    # Make user superuser # https://learn.microsoft.com/en-us/microsoft-365/bookings/add-staff?view=o365-worldwide
    # This is give someone access to the Bookings Calendar, but they are not to be bookable themselves in the calendar. 
    $SuperUsers = @(
        "someone@domain.com"
        "someone@domain.com"
        "someone@domain.com"
    )

    foreach ($superuser in $SuperUsers) {
        Add-MailboxPermission -Identity $CreatedBookingsCalendarIdentity -User $superuser -AccessRights FullAccess -InheritanceType All 
        Add-RecipientPermission -Identity $CreatedBookingsCalendarIdentity -Trustee $superuser -AccessRights SendAs -Confirm:$false
    }

    # Distribution Group
    New-DistributionGroup -Name "All Bookable Resources"
    Set-DistributionGroup -identity "All Bookable Resources" -RoomList # change to roomlist after changing from equipment>room mailboxes
    get-DistributionGroup "All Bookable Resources" | Format-List

    # Create Array list for all the bookable resources to be created
    $ResourceList = @(
        "Company Car 01"
        "Company Car 02"    
        "Company Meeting Room 01"
        "Company Meeting Room 02"    
        "Company Appartment 01"
        "Company Appartment 02"
    )

    # Create mailboxes from the array and add to distribution list
    foreach ($resource in $ResourceList) {
        $resourcedotted = $resource.ToLower() -replace "-", "" -replace " ", "." 
        New-Mailbox -Name $resourcedotted -DisplayName "$resource" -room # PS!: use room mailboxes if you want to use bookings + outlook - Equipment mailboxes will not be able to enable the "Events on personal calendar affect availability" option in bookings
        Set-Mailbox -Identity $resourcedotted -HiddenFromAddressListsEnabled $true # Enable Hide from address list
        if ($?) {
            write-host "Creation of mailbox with alias '$resourcedotted' and displayname '$resource' was succesfull" -ForegroundColor Green
            Write-Host "Will add the created mailbox '$resourcedotted' to distribution list 'All Bookable Resources'" -ForegroundColor Cyan        
            Add-DistributionGroupMember –Identity "All Bookable Resources" -Member $resourcedotted
            if ($?) { 
                Write-Host "'$resourcedotted' successfully added to distribution list" -ForegroundColor Green
                Write-Host ""
            }
            else {
                write-host "adding '$resourcedotted' to distribution list failed" -ForegroundColor red
                Write-Host ""
            }
        }
        else {
            write-host "Creation of mailbox with alias '$resourcedotted' and displayname '$resource' failed" -ForegroundColor red
            Write-Host ""
        }
    }

    # List all members of the distribution group
    Get-DistributionGroupMember -Identity "All Bookable Resources" | Select-Object name, displayname, RecipientTypeDetails | Format-Table -AutoSize
    
    # Add delegate permission | The Automapping feature is also disabled to avoid getting all the shared mailboxes listed in the outlook client
    foreach ($resource in $resourceList) {
        $resourcedotted = $resource.ToLower() -replace "-", "" -replace " ", "." 
        foreach ($superuser in $SuperUsers) {
            Add-MailboxPermission -Identity "$resourcedotted" -User $superuser -AccessRights FullAccess -AutoMapping $false -InheritanceType All
            if ($?) {    
                Write-Host "'$superuser' successfully added as delegate for the resource '$resourcedotted'" -ForegroundColor Green
            }
            else {
                Write-Host " Failed to add '$superuser' as delegate for the resource '$resourcedotted'" -ForegroundColor red
            }
        }    
    }
    # Change the default calenar permissions for the shared mailboxes to limited details so other can see more than free/busy
    # Variables
    $NameSearchTag = "*company*" # Just to have something to search for in the bookable resources (Resource list)
    $ExcludedAlias = "*Alias To Exclude*" # edit if needed, if not needed, remove it from the 'where-object' part on line 28 and line 32
    $ExcludedName = "*Name To Exclude*" # edit if needed, if not needed, remove it from the 'where-object' part on line 28 and line 32
    $IncludeSharedMailboxes = $false # set to false to process user and not include shared mailboxes - set to true to only process shared mailboxes.
    $DefaultPermission = "LimitedDetails" # Default internal org permissions - see info in link at the top of script for MS article with all the various permissions.

    # Display targeted mailboxes
    Write-Host "The script will target the following users/mailboxes" -ForegroundColor Yellow
    get-mailbox | Where-Object { $_.IsShared -eq $IncludeSharedMailboxes -and $_.alias -notlike "${ExcludedAlias}" -and $_.Name -like "${NameSearchTag}" -and $_.Name -notlike "${ExcludedName}" } | Select-Object Name, Alias | Format-Table -AutoSize
    Write-Host ""

    # Get targeted mailboxes alias
    $MailboxAlias = get-mailbox | Where-Object { $_.IsShared -eq $IncludeSharedMailboxes -and $_.alias -notlike "${ExcludedAlias}" -and $_.Name -like "${NameSearchTag}" -and $_.Name -notlike "${ExcludedName}" } | Select-Object -ExpandProperty alias

    # Change default permissions
    foreach ($mailbox in $MailboxAlias) {
        write-host "############ Processing mailbox '$mailbox' ############"
        # Get default calendar name
        $GetCalendarName = Get-MailboxFolderStatistics -Identity "$mailbox" -FolderScope Calendar |  Where-Object { $_.foldertype -eq "Calendar" } | Select-Object -ExpandProperty Identity
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

    # Time and regional settings
    $params = @{
        TimeZone   = "W. Europe Standard Time"
        TimeFormat = "HH:mm"
        DateFormat = "dd.MM.yyyy"
        Language   = "nb-NO"
    }

    foreach ($resource in $ResourceList) {
        $resourcedotted = $resource -replace " ", "."
        Set-MailboxRegionalConfiguration -Identity "$resourcedotted" @params
    }

    # Set primary smtp address for mailboxes
    $PrimaryDomain = Get-AcceptedDomain | Where-Object default -eq True | Select-Object -ExpandProperty DomainName

    foreach ($resource in $ResourceList) {
        $resourcedotted = $resource.ToLower() -replace "-", "" -replace " ", "." 
        $GeneratedEmailAddress = "$resourcedotted" + "@" + "$primarydomain"
        Write-host "Configuring primary SMTP for '$resourcedotted'...." -ForegroundColor Cyan
        Set-Mailbox -Identity $resourcedotted -WindowsEmailAddress "$GeneratedEmailAddress"
        if ($?) {
            Write-host "Successfully set primary SMTP address for mailbox '$resourcedotted'  to '$GeneratedEmailAddress'" -ForegroundColor Green
            Write-host ""
        }
        else {
            Write-host "Failed to set primary SMTP address for mailbox '$resourcedotted'  to '$GeneratedEmailAddress'" -ForegroundColor red
            Write-host ""
        }
    }

    # Show exisiting privacy settings
    Get-Mailbox -RecipientTypeDetails  EquipmentMailbox | Get-CalendarProcessing | Select-Object identity, addorganizertosubject, deletesubject, deletecomments, removeprivateproperty | Format-Table -AutoSize
    Get-Mailbox -RecipientTypeDetails  RoomMailbox | Get-CalendarProcessing | Select-Object identity, addorganizertosubject, deletesubject, deletecomments, removeprivateproperty | Format-Table -AutoSize

    # Change privacysettings
    foreach ($Resource in $ResourceList) {
        $resourcedotted = $resource.ToLower() -replace "-", "" -replace " ", "." 
        write-host "Changing calendar processing settings for mailbox '$resourcedotted'" -ForegroundColor Cyan
        get-mailbox -Identity "$resourcedotted" | Set-CalendarProcessing -AddOrganizerToSubject $false -DeleteSubject $false -DeleteComments $false -RemovePrivateProperty $false
        if ($?) {
            write-host ""
            write-host "Calendar processing settings changed for mailbox '$resourcedotted'" -ForegroundColor green
            Get-Mailbox -Identity "$resourcedotted" | Get-CalendarProcessing | Select-Object identity, addorganizertosubject, deletesubject, deletecomments, removeprivateproperty | Format-Table -AutoSize
            write-host ""
        }
    }

    # Cleanup Variables part 2
}
finally {
    Get-Variable |
    Where-Object Name -notin $existingVariables.Name |
    Remove-Variable
}