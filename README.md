# Collection of Powershell scripts
also available via https://dybbugt.no/fieldnotes/powershell/
 
Here you will find various powershell scripts/commands that can be useful in various circumstances.
The content list below show the current available scripts for you to find.

I will add more as I make them, and if they are suited to be generalized and made available to others.
If I find some useful scripts elsewhere, I will add those aswell – with notes on who is the creator.

Hope you find the content useful.

Content available:

# Office 365
**|—-Script to download and install latest version via the Office Deployment tool (Click to run)**
<br>
*Remember to input your XML file in the script*
# FSLogix
**|—-Script to download and install latest version+removes the memberships for the default everyone group after install**
 <br>
*also removes the default everyone group from the include group for Profile containers and office 365 containers*
# Microsoft Active Directory
**|—-Creating a default OU structure via Powershell**
<br>
**|—-Bulk creating security groups**
<br>
*Handy for repetetive/recurring task when combined with i.e the **"Creating a default OU structure via Powershell"** script found above.*
# Microsoft Group Policy
**|—-Create, link, and import a settings to the policy from a backup**
<br>
*This was initially created to ease repetetive task when setting up a Citrix deployment where the structure and "default" policy was something that always where the same. 
It has been generalized and changed to be put available for you here, and serves just for you to build upon yourself.
<br>
For simplicity, the below script is using the paths and variables from the script **"Creating a default OU structure via Powershell"** under the Active Directory areaon this website.*
# Microsoft DNS
**|—- Creating DNS records with powershell**
<br>
*Just a simple commandlist for creating a-records and conditional forwarders with powershell, to be included in other scripts:)*
# Citrix
**|—-Script to download and install latest version of Citrix Workspace/Receiver.**
<br>
*Intended to run via Intune*
<br>
**|—-Script to set Citrix Files desktop app config defaults**
<br>
*Useful to force require login for recipients // enable encrypted email as default etc, when sharing directly from windows explorer.*
# Windows 10
**|—-Script to set wallpaper and lockscreen on Windows 10 clients**
<br>
*This was made to be run via Intune, but that is not a requirement.
Currently Intune requires you to have Windows 10 Educational or Enterprise to be able to set wallpaper/lockscreen via Policies in Intune. This script works around this limitation.*
<br>
**|—-Script to uninstall preinstalled APPX packages on Windows 10**
<br>
*This was made to be run via Intune, but that is not a requirement*
