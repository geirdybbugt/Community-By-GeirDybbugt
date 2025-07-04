# Remediation to detect and remove Apple Bonjour if installed

After Windows 11 24H2 users  may get a popup from program compatability assistant that the module mdnsNSP.dll is blocked from loading. 
THe module is a part of Apple Bonjour, typically used for printers, airplay features etc looking for devices on the network. 
It may be installed by other sofware using the component. 
This dll is also known to be exploited. THere is no newer version of Bonjour. 
The dll is regarded as untrusted by Windows Local Security Authoity (LSA), and is blocked from loading. 

You can get around this by adding it in registry (HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa)
But this is not a valid option, and decreases your device security around credential theft. 

Some users states that installing Bonjour Print Services 2.0.2 gets around the issue, en even older version

: https://discussions.apple.com/thread/255869043?sortBy=rank

: 2.0.2 can be found here:

githttps://support.apple.com/en-us/106380

If you do not need Bonjour, it is a better option to remove it. 
So in this folder is a remediation script to be used to remove it on detected devices. 
You can use Assigment filters in intune to create a filter to only target managed devices, starting with OS Version 10.0.26100 to only affect W11 24H2 devices. 

Filter rule syntax:
(device.osVersion -startsWith "10.0.26100") and (device.deviceOwnership -eq "Corporate")

# AppleBonjour_Detect
Looks in registry uninstall information if Bonjour is installed
<br>

# AppleBonjour_Remediate
Uninstalls Bonjour if installed
<br>