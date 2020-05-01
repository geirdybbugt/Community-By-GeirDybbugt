####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

# Enable OneDrive Modern Authentication for current user 
# PS PS: When deploying with intune set  the following
		## "Run this script using the logged on credentials" to yes. 
		## "Enforce script signature check" to no. 
		## "Run script in 64 bit PowerShell Host" to no. 
		
		
$registryPath = "HKCU:\SOFTWARE\Microsoft\OneDrive"
$Name = "EnableADAL"
$value = "1"
IF(!(Test-Path $registryPath))
{
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}
ELSE {
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}