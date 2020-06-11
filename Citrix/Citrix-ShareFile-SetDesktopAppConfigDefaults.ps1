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

#Set new defaults
#PS: 'null' is the default value after fresh install, if they have been manually changed by user, the value is true or false, adapt accordingly

    #Set recipient to require login as default
    (Get-Content $JSON).replace('"Send_RequireRecipientLogin":null', '"Send_RequireRecipientLogin":true') | Set-Content $JSON

    #Set Encrypted email as default
    (Get-Content $JSON).replace('"Send_EncryptEmail":null', '"Send_EncryptEmail":true') | Set-Content $JSON

    #Set Default expiration for links to 6 months (value in days) PS: "-1"  is default for "never"
    (Get-Content $JSON).replace('"Send_Expiration":null', '"Send_Expiration":180') | Set-Content $JSON

#Start Citrix Files after change
start-process "C:\Program Files\Citrix\Citrix Files\CitrixFiles.exe"