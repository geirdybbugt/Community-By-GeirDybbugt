####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####
# PS: this scripts assumes in this example that the the OU "CONTOSO" exists under the ROOT in AD - adapt accordingly with correct paths. 

#Getting Variable for domain FQDN
    $rootDN = (Get-ADDomain).DistinguishedName

# OU locations
    $RootOU ="CONTOSO" # The toplevel folder that will serve as the Container for the AD structure
    $SecurityGroupOU = "SecurityGroups" # The folder that will contain the Security Groups

#Creating the OU for SecurityGroups
    New-ADOrganizationalUnit -Name "$SecurityGroupOU" -Path "OU=$RootOU ,$rootDN" -Description "Folder to Organize security groups used in deployment" -PassThru

#Creating the Default groups for normal Citrix Deployments
#The groups to create are: 

    $groupname = @(
    "sec-something-group1"
    "sec-something-group2"
    "sec-something-group3"  
    )
    
    ForEach($group in $groupname){
    New-ADGroup -Path "OU=$SecurityGroupOU,OU=$RootOU ,$rootDN" -Name $group -GroupScope DomainGlobal -GroupCategory Security 
    }		