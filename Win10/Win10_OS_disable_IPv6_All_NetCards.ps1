 <# Script to disable IPv6 on all ethernet cards on device. Intended to run with intune.  
 IPv6 causes issues with DNS via VPN in some scenarios, hence the script. 
 
 Edited: 08.12.21 - @Geir Dybbugt - Dybbugt.no 
 #>
 
 # Get a list of all the network cards on the device and save to array
 $netcards = @(Get-NetAdapterBinding -ComponentID ms_tcpip6 |Select-object -ExpandProperty name)

 # Disable IPv6 on all cards in the list
 Foreach ($netcard in $netcards)
    {
     Disable-NetAdapterBinding -Name "$netcard" -ComponentID ms_tcpip6
    }