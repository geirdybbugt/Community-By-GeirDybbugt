####------------------------------------------------------------------------####
#### Script to download and set the Lockscreen and Wallpaper for the user
#### Can be deployed on Win10 Pro  - also via Intune
#### Based upon the script located here: https://abcdeployment.wordpress.com/2017/04/20/how-to-set-custom-backgrounds-for-desktop-and-lockscreen-in-windows-10-creators-update-v1703-with-powershell/
####
#### Editor info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

# Parameters for source and destination for the Image file
    # Current script is edited to put the same image on LockScreen and Wallpaper

    $WallpaperURL = "WALLPAPERURL" # Change to your fitting
    $LockscreenUrl = "LOCKSCREENURL" # Change to your fitting

    $ImageDestinationFolder = "c:\temp" # Change to your fitting - this is the folder for the wallpaper image
    $WallpaperDestinationFile = "$ImageDestinationFolder\wallpaper.png" # Change to your fitting - this is the Wallpaper image
    $LockScreenDestinationFile = "$ImageDestinationFolder\LockScreen.png" # Change to your fitting - this is the Lockscreen image

# Creates the destination folder on the target computer
    md $ImageDestinationFolder -erroraction silentlycontinue

# Downloads the image file from the source location - C:\Users\Public\Pictures\
    Start-BitsTransfer -Source $WallpaperURL -Destination "$WallpaperDestinationFile"
    Start-BitsTransfer -Source $LockscreenUrl -Destination "$LockScreenDestinationFile"

# Variables
    # To set the LockScreen - cannot be changed by the user
        $RegKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    # To inject the initial wallpaper to the last logged on user on the device - as system - can be changed by the user
        $RegKeyPathUser = 'HKCU:\Control Panel\Desktop'
    # To inject the initial wallpaper for the ".Default"  user profiles, so all new users never logged on gets it the first time. 
        $RegKeyPatNewhUser = 'HKCU:\Control Panel\Desktop'
        
# PersonalizationCSP values
    $DesktopPath = "DesktopImagePath"
    $DesktopStatus = "DesktopImageStatus"
    $DesktopUrl = "DesktopImageUrl"
    $LockScreenPath = "LockScreenImagePath"
    $LockScreenStatus = "LockScreenImageStatus"
    $LockScreenUrl = "LockScreenImageUrl"

    $StatusValue = "1"
    $DesktopImageValue = "$WallpaperDestinationFile"  
    $LockScreenImageValue = "$LockScreenDestinationFile"

# Starting configuration

IF(!(Test-Path $RegKeyPath))

{

New-Item -Path $RegKeyPath -Force | Out-Null

New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null

}

ELSE {

New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $Statusvalue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $Statusvalue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
}


# Restart explorer.exe
    stop-process -name explorer –force

# Clears the error log from powershell before exiting
    $error.clear()