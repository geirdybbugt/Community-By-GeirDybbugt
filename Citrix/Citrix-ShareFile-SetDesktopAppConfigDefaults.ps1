####------------------------------------------------------------------------####
#### Script to set the Citrix Files desktop app config defaults
#### Useful to force require login for recipients // enable encrypted email as default etc, when sharing directly from windows explorer. 
#### This is not available pr now to set via Group Policy or web gui for the Citrix Files desktop app, only for outlook plugin. 
#### 
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####


#finding and terminating running Citrix Files process before changing config
# get Citrix Files process
#$procid=(get-process citrixfiles).id##

#$CitrixFiles = Get-Process CitrixFiles -ErrorAction SilentlyContinue
#if ($CitrixFiles) {
#  # try gracefully first
#  $CitrixFiles.CloseMainWindow()
#  # kill after five seconds
#  Sleep 5
#  if (!$CitrixFiles.HasExited) {
#    $CitrixFiles | Stop-Process -Force
#  }
#}
#Remove-Variable CitrixFiles

#kill process on user level without admin right
wmic process where "name='citrixfiles.exe'" delete
sleep 10

#Location for the JSON config file for Citrix Files
$JSON = "$env:appdata\Citrix\Citrix Files\users.json"

#Set recipient to require login as default
(Get-Content $JSON).replace('"Send_RequireRecipientLogin":false', '"Send_RequireRecipientLogin":true') | Set-Content $JSON

#Set Encrypted email as default
(Get-Content $JSON).replace('"Send_EncryptEmail":false', '"Send_EncryptEmail":true') | Set-Content $JSON

#Set Default expiration for links to 6 months (value in days) PS: "-1"  is default for "never"
(Get-Content $JSON).replace('"Send_Expiration":-1', '"Send_Expiration":180') | Set-Content $JSON

#Start Citrix Files after change
start-process "C:\Program Files\Citrix\Citrix Files\CitrixFiles.exe"