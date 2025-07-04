# Remediate - uninstall bonjour if found to be installed

$app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -contains "Bonjour" }


 if ($app -ne $null) {
	$app.Uninstall()
} else {
	Write-Output "Application not found."
}
