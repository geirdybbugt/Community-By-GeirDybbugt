# Detect if bonjour is installed
    $SearchPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall,HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

    $TestForBonjour = Get-ChildItem $($SearchPath -split ",") -Recurse  | Get-ItemProperty | Where-Object {$_.DisplayName -Like "Bonjour" } | Select-Object -ExpandProperty Displayname
    $result = $TestForBonjour -match "Bonjour"

    if ($result)
     {
        Write-Output "Bonjour installed, remediation needed"
        exit 1
     }
     else
     {
        Write-Output "Bonjour missing, no change needed"
        exit 0
     }