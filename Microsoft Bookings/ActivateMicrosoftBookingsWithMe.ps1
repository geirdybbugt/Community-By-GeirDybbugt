<#
Microsoft Bookings With Me
Create a new policy to activate the bookings with me feature for selected users.

https://support.microsoft.com/en-gb/office/bookings-with-me-setup-and-sharing-ad2e28c4-4abd-45c7-9439-27a789d254a2
#>

# Connect to Exchange Online
Connect-ExchangeOnline

#Create a sharing policy to enable bookings with me
$PolBookingsWithMe = "EnableBookWithMe"

New-SharingPolicy -Name $PolBookingsWithMe -Domains Anonymous:CalendarSharingFreeBusySimple
Set-SharingPolicy -Identity $PolBookingsWithMe -Domains @{Add = "*:CalendarSharingFreeBusySimple" }

# Add users to the policy
$Users = @(
    "user1@domain.com"
    "user2@domain.com"
)

foreach ($user in $Users) {
    Set-Mailbox -identity $user -SharingPolicy $PolBookingsWithMe
}

Remove-Variable PolBookingsWithMe
Remove-Variable Users