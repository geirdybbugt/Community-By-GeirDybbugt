####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

# Enable Silent Configurating and Files on Demand for OneDrive for Business 
# PS PS: When deploying with intune set  the following
		## "Run this script using the logged on credentials" to no. 
		## "Enforce script signature check" to no. 
		## "Run script in 64 bit PowerShell Host" to no. 


$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$Name = "SilentAccountConfig"
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
$Name = "FilesOnDemandEnabled"
$value = "1"
IF(!(Test-Path $registryPath))
{
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}
ELSE {
New-ItemProperty -Path $registryPath -Name $name -Value $value `
-PropertyType DWORD -Force | Out-Null}