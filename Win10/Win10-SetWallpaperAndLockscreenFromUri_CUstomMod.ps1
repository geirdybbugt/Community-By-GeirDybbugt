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
    IF(!(Test-Path $ImageDestinationFolder)){
        md $ImageDestinationFolder -erroraction silentlycontinue
        }

# Downloads the image file(s) from the source location(s)
    Start-BitsTransfer -Source $WallpaperURL -Destination "$WallpaperDestinationFile"
    Start-BitsTransfer -Source $LockscreenUrl -Destination "$LockScreenDestinationFile"

# Registry location variables
    # General
        $RegPathDesktopWallpaper = "Control Panel\Desktop"

    # Get info about the last logged on user
        $GetLastLoggedOnUser = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
        $LastLoggedOnUserSID = Get-ItemProperty -Path $GetLastLoggedOnUser
        $LastLoggedOnUserSID = $LastLoggedOnUserSID.LastLoggedOnUserSID

    # To set the wallpaper and lockscreen - cannot be changed by the user
        $RegKeyPathCSP = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

    # To inject the initial wallpaper to the current user - can be changed by the user
        $RegKeyPathUser = "HKCU:\$RegPathDesktopWallpaper"

    # To inject the initial wallpaper for the ".Default" user profiles, so all new users never logged on gets it the first time. 
        $RegKeyPathDefaultProfile = "HKU:\.DEFAULT\$RegPathDesktopWallpaper"

    # To inject the initial wallpaper to the last logged on user on the device - as system - can be changed by the user
        $RegKeyPathLastUser = "HKU:\$LastLoggedOnUserSID\$RegPathDesktopWallpaper"

        
# PersonalizationCSP values
    # Lockscreen CSP - HKLM
        $LockScreenImageValue = "$LockScreenDestinationFile"
        $LockScreenPath = "LockScreenImagePath"
        $LockScreenStatus = "LockScreenImageStatus"
        $LockScreenUrl = "LockScreenImageUrl"

    # Wallpaper CSP - HKLM
        $DesktopImageValue = "$WallpaperDestinationFile"  
        $DesktopPath = "DesktopImagePath"
        $DesktopStatus = "DesktopImageStatus"
        $DesktopUrl = "DesktopImageUrl"

    # Status
        $StatusValue = "1"

    # wallpaper and paths normal user - HKCU/.Default
        $WallpaperPath = "WallPaper"
        $WallpaperPathValue = "$WallpaperDestinationFile"
        $RegPath = "Control Panel\Desktop"


# Starting configuration
    # Lockscreen - cannot be changed by the user
        if(!(Test-Path $RegKeyPathCSP))
        {
        New-Item -Path $RegKeyPathCSP -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        } else {
        New-ItemProperty -Path $RegKeyPathCSP -Name $LockScreenStatus -Value $Statusvalue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        }

    # Wallpaper - cannot be changed by the user
        if(!(Test-Path $RegKeyPathCSP))
        {
        New-Item -Path $RegKeyPathCSP -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
        } else {
        New-ItemProperty -Path $RegKeyPathCSP -Name $DesktopStatus -Value $Statusvalue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathCSP -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
        }

    # Wallpaper - for current user with standard rights        
        if(!(Test-Path $RegKeyPathUser))
        {
        New-Item -Path $RegKeyPathUser -Force | Out-Null
        New-ItemProperty -Path $RegKeyPathUser -Name $WallpaperPath -Value $WallpaperPathValue -PropertyType STRING -Force | Out-Null
        } else {
        New-ItemProperty -Path $RegKeyPathUser -Name $WallpaperPath -Value $WallpaperPathValue -PropertyType STRING -Force | Out-Null
        }

    # Section to set values via HKU as System user - to last logged on user on device and the .Default profile

        # Map HKU in registry as available drive in OS
            New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

        # Set the config
            # Set the config values for the last logged on user
                if((Test-Path -LiteralPath $RegKeyPathLastUser) -ne $true) {
                    New-Item $RegKeyPathLastUser -force
                        if ($?) {
                        New-ItemProperty -LiteralPath "$RegKeyPathLastUser" -Name $WallpaperPath -Value $WallpaperPathValue -PropertyType String -Force -ea SilentlyContinue;
                        } else {
                            write-host "failed" -ForegroundColor Red
                            }
                    } else { 
                    New-ItemProperty -LiteralPath "$RegKeyPathLastUser" -Name $WallpaperPath -Value $WallpaperPathValue -PropertyType String -Force -ea SilentlyContinue;
                    }

            # Set the config values for the .Default profile
                if((Test-Path -LiteralPath $RegKeyPathDefaultProfile) -ne $true) {
                    New-Item $RegKeyPathDefaultProfile -force
                        if ($?) {
                        New-ItemProperty -LiteralPath "$RegKeyPathDefaultProfile" -Name $WallpaperPath -Value $WallpaperPathValue -PropertyType String -Force -ea SilentlyContinue;
                        } else {
                            write-host "failed" -ForegroundColor Red
                            }
                    } else { 
                    New-ItemProperty -LiteralPath "$RegKeyPathDefaultProfile" -Name $WallpaperPath -Value $WallpaperPathValue -PropertyType String -Force -ea SilentlyContinue;
                    }

        # Unmap HKU from available PS drives before exiting
                Remove-PSDrive hku

# Restart explorer.exe
    stop-process -name explorer –force

# Clears the error log from powershell before exiting
    $error.clear()