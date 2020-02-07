####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####
# PS: this script is using dummy names and paths - adapt accordingly with correct paths. 

#Getting Variable for domain FQDN
    $rootDN = (Get-ADDomain).DistinguishedName

#Setting the variables
    $RootOU="CONTOSO" #The toplevel folder that will serve as the Container for everyting in the organization
    $UsersOU = "Users" #The Folder that will conatin the user objects
    $ComputersOU = "Computers" #The Folder that will contain the computer objects
    $ServersOU = "Servers" #The Folder that will contain the server objects
    $SecurityGroupOU = "SecurityGroups" #The folder that will contain the Security Groups for the organization

#Creating the OU structure for Active Directory

    New-ADOrganizationalUnit -Name "$RootOU" -Path "$rootDN" -Description "Container for everyting in the organization" -PassThru
    New-ADOrganizationalUnit -Name "$UsersOU" -Path "OU=$RootOU,$rootDN" -Description "conatiner for user objects" -PassThru
    New-ADOrganizationalUnit -Name "$ComputersOU" -Path "OU=$RootOU,$rootDN" -Description "conatiner for computer objects" -PassThru
    New-ADOrganizationalUnit -Name "$ServersOU" -Path "OU=$RootOU,$rootDN" -Description "conatiner for server objects" -PassThru
    New-ADOrganizationalUnit -Name "$SecurityGroupOU" -Path "OU=$RootOU,$rootDN" -Description "Folder to Organize security groups used in deployment" -PassThru