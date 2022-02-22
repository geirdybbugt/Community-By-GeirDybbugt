# Collection of Powershell scripts
also available via https://dybbugt.no/fieldnotes/powershell/
 
Here you will find various powershell scripts/commands that can be useful in various circumstances.
The content list below show the current available scripts for you to find.

I will add more as I make them, and if they are suited to be generalized and made available to others.
If I find some useful scripts elsewhere, I will add those aswell – with notes on who is the creator.

Hope you find the content useful.

Content available:

# TeamsVDI-NonVDI-BugFix_2022.ps1
**|—-This package was created due to an apparent bug on Microsoft Teams introduced in the 1.5 release from Microsoft.**
 Users are experiencing issues with calling, conferencing etc after update to 1.5.2164 version of Teams.
 Issues revolve around the functionality is just not working, gives error etc. 
 Downgrading to 1.4 resolves the issue. But, Teams gets auto updated. 
 Users especcially affected are users with devices controlled via Endpoint Manager/intune Azure join etc. 
 Users then typically has a Display Name set on their users in Azure including "(Something)" i.e "John Smith (Sales)". 
 Azure uses this to generate the folder name for the local user profiles giving issues to some users with long names. 
 This results in the folder getting a name with a non enclosing parenthesis like so: "John Smith(" - this seems to break functionality with some apps, including Teams after 1.5.x release. 
 
 **Note for Microsoft** - if they somehow sees this - please use Alias/identity,mailnickname or anything other than Display Name  to generate this folder name - Display Name is not suited for this.
 <br>
 Display name can also include special characters or non english characthers that also can cause challanges down the road.  
 A workaround to this problem for now, is to use the VDI installer, this installer has auto updated disabled when installed correctly.
 But, to install the VDI installer onto Non-VDI machines some tweaks need to be made.
 <br>
 This script will: 
 - Stop running Teams
 - Uninstall existing versions (machin installer and user installer)
 - Clear the Teams Cache from user profiles
 - Clear web browser caches - Teams caches stuff there as well... You will be warned before this step with a confirmation
 - Set the needed registry key to be able to install the VDI installer to NON-VDI machines
 - Download the MSI based VDI installer from Microsoft version 1.4.00.2781 for x64. 
 - Install it onto the machine
 - Start Teams when installed
 <br>
 Auto updates is then disabled until permanent fix from Microsoft is available in the normal installer.
<br>
Refrences talking about the issues: 
<br>
 https://techcommunity.microsoft.com/t5/microsoft-teams/teams-version-1-5-00-2164-bug/m-p/3150143
 https://docs.microsoft.com/en-us/answers/questions/730769/teams-version-15002164-bug.html
 https://www.theregister.com/2022/02/15/microsoft_teams_outage/
<br>
# TeamsVDI-NonVDI-BugFix_2022.exe
**|—-This package was created due to an apparent bug on Microsoft Teams introduced in the 1.5 release from Microsoft.**
This is an EXE installer of the PS1 script above, just to make it easy for the users to quickly run the installer.
Not everyone os comfortable with running PowerShell scripts etc. 
<br>
*The EXE will ask for elevation. Conversion to EXE is done with ps2exe module.* 
# Revert_TeamsVDI-NonVDI-BugFix_2022.ps1
**|—-This package was created due to an apparent bug on Microsoft Teams introduced in the 1.5 release from Microsoft.**
 <br>
This package reverts the bugfix from 2022 issues back to normal per machine installer with updates enabled and cleans away the non vdi requirements.
This makes is easy for the users to jump back to a normal installation of Teams after the issue has been resolved.
<br>
 This script will: 
 - Stop running Teams
 - Uninstall existing versions (machin installer and user installer)
 - Clear the Teams Cache from user profiles
 - Clear web browser caches - Teams caches stuff there as well... You will be warned before this step with a confirmation
 - Remove the needed registry key to be able to install the VDI installer to NON-VDI machines
 - Download the latest MSI based  installer from Microsoft for x64. 
 - Install it onto the machine
 - Start Teams when installed to inject it into the users profile for user based installation as normal
 <br>
*Microsoft Teams is then back to the normal machine installer with the latest version with updates enabeld*
# Revert_TeamsVDI-NonVDI-BugFix_2022.exe
This is an EXE installer of the PS1 script above, just to make it easy for the users to quickly run the installer.
Not everyone os comfortable with running PowerShell scripts etc. 
<br>
*The EXE will ask for elevation. Conversion to EXE is done with ps2exe module.* 