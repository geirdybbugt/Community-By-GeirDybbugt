<# 

Script to connect to azure ad, and pull a status of the users enabled state. 

Will look for: 
    Guest users - enabled and disabled users
    Normal users - enabled and disabled
    Admin users - users with global administrator role - enabled and disabled

Will create a CSV export on your desktop with the table containing the users. 

CSV file will have seperate columns for: 
    Guest users - Enabled users column and disabled users column
    Normal users - Enabled users column and disabled users column
    Admin users - Enabled users column and disabled users column

Modified: 08.09.2022 - Geir Dybbugt
#>

# Connect to Azure AD
    Connect-AzureAD

# Get date for filename usage
    $datefilename = Get-Date -Format "dd-MM-yyyy_HH-mm"

# Location for documentation of status pr today.
    $FileLocation = [Environment]::GetFolderPath('Desktop')
    $Filename = "UserStatus_$datefilename.csv"

    IF(!(Test-Path $FileLocation)) {
        Try{
        write-host "Output folder don't exist, will create" -ForegroundColor Yellow
        md $FileLocation
        } 
        catch{
        throw "failed to create folder"
        }        
    } 
    else{
    write-host "Output folder exist" -ForegroundColor Green 
    }

# Create arrays for Enabled/Disabled Normal,Guest and Admin users
    $EnabledAdminUsers = @()
    $DisabledAdminUsers = @()

    $EnabledNormalUsers = @()
    $DisabledNormalUsers = @()

    $EnabledGuestUsers = @()
    $DisabledGuestUsers = @()

# Global Admin users - Finds the users with the Global Administrator role    
    #Find Global Admin users in directory
    $GlobalAdminObjectID = Get-AzureADDirectoryRole | Where-Object {$_.displayname -eq "Global Administrator"} | Select-Object -ExpandProperty objectid
    $GlobalAdminUsers = Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdminObjectID | Select-Object -ExpandProperty userprincipalname

    # Check the status for users
    foreach($GlobalAdminUser in $GlobalAdminUsers){
    $accountenabled = Get-AzureADUser -ObjectId "$GlobalAdminUser" | Select-Object -ExpandProperty AccountEnabled
    if($accountenabled -eq "True"){
        Write-Host "The user " -NoNewline; Write-Host "$GlobalAdminUser" -ForegroundColor Cyan -NoNewline; Write-Host " enabled-status is: " -NoNewline; Write-Host "$accountenabled" -ForegroundColor Green
        $EnabledAdminUsers += $GlobalAdminUser
        } else {
            Write-Host "The user " -NoNewline; Write-Host "$GlobalAdminUser" -ForegroundColor Cyan -NoNewline; Write-Host " enabled-status is: " -NoNewline; Write-Host "$accountenabled" -ForegroundColor Red
            $DisabledAdminUsers += $GlobalAdminUser
            }
    }

# Normal users - excluding admins
    # Find normal users in directory
    $normalusers2 = Get-AzureADUser -All $true | Where-Object {$_.usertype -eq "Member"} | Select-Object -ExpandProperty userprincipalname

    # Clean the list for users with Global admin role
        $normalusers = @()
            foreach ($user in $normalusers2) {
	            if ($GlobalAdminUsers -notcontains $user) {
		            $normalusers += $user
		            }
	            }
        
    # Check the status for users
    foreach($normaluser in $normalusers){
    $accountenabled = Get-AzureADUser -ObjectId "$normaluser" | Select-Object -ExpandProperty AccountEnabled
    if($accountenabled -eq "True"){
        Write-Host "The user " -NoNewline; Write-Host "$normaluser" -ForegroundColor Cyan -NoNewline; Write-Host " enabled-status is: " -NoNewline; Write-Host "$accountenabled" -ForegroundColor Green
        $EnabledNormalUsers += $normaluser
        } else {
            Write-Host "The user " -NoNewline; Write-Host "$normaluser" -ForegroundColor Cyan -NoNewline; Write-Host " enabled-status is: " -NoNewline; Write-Host "$accountenabled" -ForegroundColor Red
            $DisabledNormalUsers += $normaluser
            }
    }

# Guest users
    # Find guest users in directory
    $guestusers = Get-AzureADUser -Filter "UserType eq 'Guest'" | Select-Object -ExpandProperty userprincipalname
       
    # Check the status for users
    foreach($guestuser in $guestusers){
    $accountenabled = Get-AzureADUser -ObjectId "$guestuser" | Select-Object -ExpandProperty AccountEnabled
    if($accountenabled -eq "True"){
        Write-Host "The user " -NoNewline; Write-Host "$guestuser" -ForegroundColor Cyan -NoNewline; Write-Host " enabled-status is: " -NoNewline; Write-Host "$accountenabled" -ForegroundColor Green
        $EnabledGuestUsers += $guestuser
        } else {
            Write-Host "The user " -NoNewline; Write-Host "$guestuser" -ForegroundColor Cyan -NoNewline; Write-Host " enabled-status is: " -NoNewline; Write-Host "$accountenabled" -ForegroundColor Red
            $DisabledGuestUsers += $guestuser
            }
    }
    
# Create some documentation
    $EnabledAdminUsersCount = ($EnabledAdminUsers | Measure).Count
    $DisabledAdminUsersCount = ($DisabledAdminUsers | Measure).Count

    $EnabledNormalUsersCount = ($EnabledNormalUsers | Measure).Count
    $DisabledNormalUsersCount = ($DisabledNormalUsers | Measure).Count

    $EnabledGuestUsersCount = ($EnabledGuestUsers | Measure).Count
    $DisabledGuestUsersCount = ($DisabledGuestUsers | Measure).Count

    $MaxUserCount = ($EnabledAdminUsersCount,$DisabledAdminUsersCount,$EnabledNormalUsersCount,$DisabledNormalUsersCount,$EnabledGuestUsersCount,$DisabledGuestUsersCount | Measure -Maximum).Maximum
    
    # Prepare an array
        $ExportArray = For ($Inc = 0; $Inc -lt $MaxUserCount; $Inc++) {

            If ($Inc -ge $EnabledAdminUsersCount) {$EnabledAdminUsersName = $Null}
            Else {$EnabledAdminUsersName = $EnabledAdminUsers[$Inc]}

            If ($Inc -ge $DisabledAdminUsersCount) {$DisabledAdminUsersName = $Null}
            Else {$DisabledAdminUsersName = $DisabledAdminUsers[$Inc]}

            If ($Inc -ge $EnabledNormalUsersCount) {$EnabledNormalUsersName = $Null}
            Else {$EnabledNormalUsersName = $EnabledNormalUsers[$Inc]}

            If ($Inc -ge $DisabledNormalUsersCount) {$DisabledNormalUsersName = $Null}
            Else {$DisabledNormalUsersName = $DisabledNormalUsers[$Inc]}
    
            If ($Inc -ge $EnabledGuestUsersCount) {$EnabledGuestUsersName = $Null}
            Else {$EnabledGuestUsersName = $EnabledGuestUsers[$Inc]}

            If ($Inc -ge $DisabledGuestUsersCount) {$DisabledGuestUsersName = $Null}
            Else {$DisabledGuestUsersName = $DisabledGuestUsers[$Inc]}

            # Create custom object to export
                [pscustomobject]@{
                    "EnabledAdminUsers" = $EnabledAdminUsersName
                    "DisabledAdminUsers" = $DisabledAdminUsersName

                    "EnabledNormalUsers" = $EnabledNormalUsersName
                    "DisabledNormalUsers" = $DisabledNormalUsersName

                    "EnabledGuestUsers" = $EnabledGuestUsersName
                    "DisabledGuestUsers" = $DisabledGuestUsersName
                }
            }

    # Show result on screen
        $ExportArray | ft -AutoSize

    # Export to CSV
        $ExportArray | Export-Csv -Path "$FileLocation\$Filename" -Encoding UTF8 -Force -NoTypeInformation