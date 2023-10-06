# Collection of Powershell scripts
also available via https://dybbugt.no/fieldnotes/powershell/
 
Here you will find various powershell scripts/commands that can be useful in various circumstances.
The content list below show the current available scripts for you to find.

I will add more as I make them, and if they are suited to be generalized and made available to others.
If I find some useful scripts elsewhere, I will add those aswell – with notes on who is the creator.

Hope you find the content useful.

Content available:

# 7zip
**|—-Script to download and install latest version**
<br>
# Office 365
**|—-Script to download and install latest version via the Office Deployment tool (Click to run)**
<br>
*Remember to input your XML file in the script*
# Buypass Javafri
**|—-Script to download and install latest version**
<br>
# Citrix
**|—-Script to download and install latest version of Citrix Workspace/Receiver.**
<br>
*Intended to run via Intune*
<br>
**|—-Script to set Citrix Files desktop app config defaults**
<br>
*Useful to force require login for recipients // enable encrypted email as default etc, when sharing directly from windows explorer.*
<br>
**|—-Script to Remove windows store Workspace app and install native client**
<br>
# FSLogix
**|—-Script to download and install latest version**
 <br>
*also removes the default everyone group from the include group for Profile containers and office 365 containers*
# Intune
**|—-Script to get device hash**
 <br>
**|—-Script collection used to create single app kosk deployment**
<br>
*This collection is made available in context of the following blog post.:
*https://hacking-windows-kiosk-mode-single-intune-config-for-multiple-devices-needing-unique-urls-with-self-provisioning-autopilot
*Read the post to see the full details of the deployment for this. 
*I am that there are duplicate script sections in the files located here, this was intended initially, cleanup should you need/want. 
*All scripts are provided as is for use at your own risk, always do proper testing.*
# KeePass
**|—-Script to download and install latest version**
<br>
# Microsoft Bookings
**|—-Script to download and install latest version**
<br>
# Microsoft Edge
**|—-Script to activate BookingsWithMe feature**
 <br>
**|—-Script used for demo deployment of Microsoft Bookings **
# Microsoft Office
**|—-Script to download and install latest version (365 for VDI)**
 <br>
*Used to deploy office 365 installation on VDI/RDS*
<br>
**|—-Script to set Outlook programatic security settings**
# Microsoft Teams
**|—-Script to download and install latest version**
 <br>
*Downloads and install Microsoft Teams x64 for VDI*
# Office 365
**|—-Various scripts used agains O365 services**
 <br>
# OneDrive
**|—-Scripts to deploy with intune to configure OneDrive for Business with Known Folder management silently**
<br>
*View comments in the individual scripts for deployment instructions for Intune*
<br>
**|—-Script to download and install latest version**
<br>
*Downloads and install latest with Alluser switch, and unregister update tasks*
# TeamViewer
**|—-Script to download and install latest version to desktop for user**
<br>
*Used with intune*
# Windows Server
**|—-Script to install a fresh NPS server used with the Azure MFA extension**
*Will install NPS role, download and install Azure MFA extension, then give you promts underway for input.*
*PS: I tend to but Radius behind LoadBalancers on NetScaler/ADC, therefore the SNIP is used. If no LoadBalancing input NSIP instead*
<br>
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
# Windows 10
**|—-Script to set wallpaper and lockscreen on Windows 10 clients**
<br>
*This was made to be run via Intune, but that is not a requirement.
Currently Intune requires you to have Windows 10 Educational or Enterprise to be able to set wallpaper/lockscreen via Policies in Intune. This script works around this limitation.*
<br>
**|—-Script to uninstall preinstalled APPX packages on Windows 10**
<br>
*This was made to be run via Intune, but that is not a requirement*
<br>
**|—-Script to Disable IPv6**
<br>
**|—-Script to disable upgrade from Win10 > Win11**
<br>
**|—-Script to set Screensaver on non-enterprise windows edition**
