####------------------------------------------------------------------------####
#### Editor info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

## source.: https://www.pdq.com/blog/remove-appx-packages/
## Microsoft app list source: https://docs.microsoft.com/en-us/windows/application-management/apps-in-windows-10

# Uninstall Windows 10 preinstalled apps for current user 

$appname = @(
"*Print3D*"
"*MixedReality.Portal*"
"*SkypeApp*"
"*XboxApp*"
"*XboxGamingOverlay*"
"*XboxGameOverlay*"
"*XboxIdentityProvider*"
"*XboxSpeech*"
"*ZuneMusic*"
"*XboxGameCall*"
"*BingWeather*"
"*GetStarted*"
"*LinkedInforWindows*"
"*FreshPaint*"
"*Microsoft.Messaging*"
"*MicrosoftSolitaireCollection*"
"*MMicrosoft.MicrosoftStickyNotes*"
"*Microsoft3dViewer*"
"*Microsoft.People*"
"*WindowsAlarms*"
"*WindowsMaps*"
"*Xbox.TCUI*"
"*Microsoft.ZuneVideo*"
"*Microsoft.YourPhone*"
"*XboxGameCallableUI_*"
"*Microsoft.GetHelp*"
"*Microsoft.MSPaint*"
"*Microsoft.OneConnect*"
"*Microsoft.Wallet*"
"*microsoft.windowscommunicationsapps*"
"*Microsoft.WindowsFeedbackHub*"
"*Microsoft.XboxSpeechToTextOverlay*"
)

ForEach($app in $appname){
Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Prevent the same apps from getting provisioned to other users on the computer

ForEach($app in $appname){
Get-AppxProvisionedPackage -Online | where {$_.PackageName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}