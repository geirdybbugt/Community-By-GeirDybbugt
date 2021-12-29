####------------------------------------------------------------------------####
#### Gets information of who is member of dynamic distribution lists
#### Exports to csv file for use elsewhere
#### You need to log in to ExOnline with valid credentials
#### 
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

# set powershell to use tls 1.2
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# Check if Exchange Online module is installed
    if (Get-Module -ListAvailable -Name ExchangeOnlineManagement) {
    Write-Host "Module exists, continuing" -ForegroundColor Green
    } 
    else {
        Write-Host "Module does not exist, starting install" -ForegroundColor Red
        Install-Module -Name ExchangeOnlineManagement
    }


# Log in to Exchange Online
    Connect-ExchangeOnline

# Location to save exported CSV
    $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

# Get running date
    $date = Get-Date -Format "dd.MM.yyyy"

# To get the dynamic lists containing "DDL" in the name
    $dynamiclists = Get-DynamicDistributionGroup "*DDL*" 

# For table later
    $Table = @()

    $Record = [ordered] @{
        "Date" = ""
        "Group Name" = ""
        "Name" = ""
        "First Name" = ""
        "Last Name" = ""
        "Display Name" = ""
        "Email" = ""
        "Department" = ""
    }

    # Get the member data
    ForEach($dynamiclist in $dynamiclists){
    $members = Get-Recipient -RecipientPreviewFilter $dynamiclist.RecipientFilter -OrganizationalUnit $dynamiclist.RecipientContainer | Select name,FirstName,LastName,DisplayName,PrimarySmtpAddress,Department
        foreach ($member in $members){
        $record."Date" = $date
        $record."Group Name" = $dynamiclist
        $record."Name" = $member.name
        $record."First Name" = $member.FirstName
        $record."Last Name" = $member.LastName
        $record."Display Name" = $member.Displayname
        $record."Email" = $member.PrimarySmtpAddress 
        $record."Department" = $member.Department
        $objRecord = New-Object PSObject -property $Record
        $Table += $objrecord
        }
    }

# Show result in console
    $Table | ft | Out-Host
    Write-host "Press any key to complete export to file and exit" -ForegroundColor Cyan
	pause

# Export to CSV file
    $Table | Export-Csv -NoTypeInformation $DesktopPath\DDL-Members-$date.csv -Encoding UTF8    

# Disconnect from Exchange Online
    Disconnect-ExchangeOnline