####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

# Enable Known Folder Management for OneDrive for Business 
# PS PS: When deploying with intune set  the following
		## "Run this script using the logged on credentials" to no. 
		## "Enforce script signature check" to no. 
		## "Run script in 64 bit PowerShell Host" to no. 

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$Name = "KFMBlockOptIn"
$value = "1"
IF(!(Test-Path $registryPath))
{
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}
ELSE {
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$Name = "KFMSilentOptIn"
$value = "439536f9-b383-4960-8c1c-b6939448a8bb"
IF(!(Test-Path $registryPath))
{
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType String -Force | Out-Null}
ELSE {
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType String -Force | Out-Null}
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$Name = "KFMSilentOptInWithNotification"
$value = "0"
IF(!(Test-Path $registryPath))
{
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}
ELSE {
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$Name = "KFMBlockOptOut"
$value = "1"
IF(!(Test-Path $registryPath))
{
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}
ELSE {
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}