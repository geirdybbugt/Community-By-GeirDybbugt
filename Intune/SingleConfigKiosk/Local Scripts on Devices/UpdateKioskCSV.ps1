<#
Script to update the local CSV file on the kiosk device
The CSV file is located in Azure Storage blob
#>

# Restart Process using PowerShell 64-bit 
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}

# Variables
$CSVDestination = "c:\Meetingrooms-csv"
$CSVName = "meetingrooms.csv"

# Get CSV from Storage blob
        
# SAS-URI for the CSV file deployed to the devices containing the URL/Country/Serialnr information
# Valid from/to: Valid from/to: 15/06/2022-->15/06/2028
$CSVDownloadSource = "###" # <----- The URI for your meetingrooms.csv file

# Update CSV file
        
# Set TLS protocol type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Downloads the file from source
Start-BitsTransfer -Source $CSVDownloadSource -Destination "$CSVDestination\$CSVName"

# Clears the error log from powershell before exiting
$error.clear()