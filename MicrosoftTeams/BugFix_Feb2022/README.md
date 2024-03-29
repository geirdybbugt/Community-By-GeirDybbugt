# Bugfix for Teams due to issues with Audio/Video introduced in certain environments after 1.5.x update
<br>
**Details about bug can be found here: https://dybbugt.no/2022/2067/**

# TeamsVDI-NonVDI-BugFix_2022.ps1
**|--This package was created due to an apparent bug on Microsoft Teams introduced in the 1.5 release from Microsoft**
Users are experiencing issues with calling, conferencing etc after update to 1.5.2164 version of Teams.
Issues revolve around the functionality is just not working, gives error etc. 
Downgrading to 1.4 resolves the issue. But, Teams gets auto updated. 
<br<
Users especcially affected are users with devices controlled via Endpoint Manager/intune Azure join etc. 
Users then typically has a Display Name set on their users in Azure including "(Something)" i.e "John Smith (Sales)". 
Azure uses this to generate the folder name for the local user profiles giving issues to some users with long names. 
This results in the folder getting a name with a non enclosing parenthesis like so: "John Smith(" 
<br>
<br>
This seems to break functionality with some apps, including Teams after 1.5.x release. 
 
**Note for Microsoft** - if they somehow sees this - please use Alias/identity,mailnickname or anything other than Display Name  to generate this folder name - 
Display Name is not suited for this.
<br>
Display name can also include special characters or non english characthers that also can cause challanges down the road.
<br>
<br>
A workaround to this problem for now, is to use the VDI installer, this installer has auto updated disabled when installed correctly.
But, to install the VDI installer onto Non-VDI machines some tweaks need to be made.
<br>
**This script will:**
<br>
 - Stop running Teams
 - Uninstall existing versions (machin installer and user installer)
 - Clear the Teams Cache from user profiles
 - Clear web browser caches - Teams caches stuff there as well... You will be warned before this step with a confirmation
 - Set the needed registry key to be able to install the VDI installer to NON-VDI machines
 - Download the MSI based VDI installer from Microsoft version 1.4.00.2781 for x64. 
 - Install it onto the machine
 - Close Outlook and register the Teams addi for Outlook 
 - Start Teams when installed
<br>
Auto updates is then disabled until permanent fix from Microsoft is available in the normal installer.
<br>
<br>
**Refrences talking about the issues:** 
<br>
https://techcommunity.microsoft.com/t5/microsoft-teams/teams-version-1-5-00-2164-bug/m-p/3150143
<br>
https://docs.microsoft.com/en-us/answers/questions/730769/teams-version-15002164-bug.html
<br>
https://www.theregister.com/2022/02/15/microsoft_teams_outage/
<br>

# TeamsVDI-NonVDI-BugFix_2022.exe
**|--This package was created due to an apparent bug on Microsoft Teams introduced in the 1.5 release from Microsoft**
This is an EXE installer of the PS1 script above, just to make it easy for the users to quickly run the installer.
Not everyone os comfortable with running PowerShell scripts etc. 
<br>
<br>
*The EXE will ask for elevation. Conversion to EXE is done with ps2exe module*
 
# Revert_TeamsVDI-NonVDI-BugFix_2022.ps1
**|--This package was created due to an apparent bug on Microsoft Teams introduced in the 1.5 release from Microsoft**
<br>
This package reverts the bugfix from 2022 issues back to normal per machine installer with updates enabled and cleans away the non vdi requirements.
<br>
This makes is easy for the users to jump back to a normal installation of Teams after the issue has been resolved.
<br>
<br>
 This script will: 
 <br>
 - Stop running Teams
 - Uninstall existing versions (machin installer and user installer)
 - Clear the Teams Cache from user profiles
 - Clear web browser caches - Teams caches stuff there as well... You will be warned before this step with a confirmation
 - Remove the needed registry key to be able to install the VDI installer to NON-VDI machines
 - Download the latest MSI based  installer from Microsoft for x64. 
 - Install it onto the machine
 - Start Teams when installed to inject it into the users profile for user based installation as normal
 <br>
 <br>
*Microsoft Teams is then back to the normal machine installer with the latest version with updates enabled*

# Revert_TeamsVDI-NonVDI-BugFix_2022.exe
This is an EXE installer of the PS1 script above, just to make it easy for the users to quickly run the installer.
Not everyone os comfortable with running PowerShell scripts etc. 
<br>
<br>
*The EXE will ask for elevation. Conversion to EXE is done with ps2exe module* 
