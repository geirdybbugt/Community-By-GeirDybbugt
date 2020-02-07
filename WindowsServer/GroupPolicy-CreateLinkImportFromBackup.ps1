####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

# The scripts assumes there is an OU called 2019-servers under the path \rootDN\Contoso\servers - adapt accordingly

#Getting Variable for domain FQDN
    $rootDN = (Get-ADDomain).DistinguishedName

#Setting the variables
    $RootOU="CONTOSO" 

#Group Policy Deployment

    #Creating Default Group Policies
	
        #For 2019 servers
        $RootOU2019 = Get-ADOrganizationalUnit -filter 'name -like "2019-servers"' -SearchBase "OU=$RootOU,$rootDN" | Select-Object -ExpandProperty Distinguishedname
        new-gpo -name 2019-servers-gpo | new-gplink -target $server2019OU

    #Importing settings from backup policy

        #For 2019 servers
        Import-GPO -BackupGpoName 2019-servers-gpo-backup -Path C:\temp\2019-servers-gpo-backup -TargetName 2019-servers-gpo -CreateIfNeeded 