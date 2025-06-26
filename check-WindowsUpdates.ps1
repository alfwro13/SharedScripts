whoami
""
Enter-PSSession -ComputerName (Read-Host "Enter Computer name or IP address") -Credential (Get-Credential) 
$ci = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate  -ClassName MSFT_WUOperationsSession
Invoke-CimMethod -InputObject $ci -MethodName  ApplyApplicableUpdates
