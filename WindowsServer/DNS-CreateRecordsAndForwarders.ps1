####------------------------------------------------------------------------####
#### Creator info: Geir Dybbugt - https://dybbugt.no
####------------------------------------------------------------------------####

# I prefer to use a-records with specific names rather than adding the whole domain.com in dns, this makes the issues around splitDNS easier. 
# Dummy IPs in this list. 

#Create A-record in DNS for record "something.domain.com" on your DNS server
    Add-DnsServerPrimaryZone -Name "something.domain.com" -ReplicationScope "Forest" -PassThru
    Add-DnsServerResourceRecordA  -name "@" -ZoneName "something.domain.com" -AllowUpdateAny -IPv4Address "1.2.3.4" -TimeToLive 01:00:00

#Creating DNS Conditional Forwarders against something.forest for use in Trust configuration later. 
    Add-DnsServerConditionalForwarderZone -Name "something.forest"  -MasterServers "1.0.0.1","1.0.0.2"