#This will open additional powershell window only from already running zamw powershell window

$username = "isys\zamw"
$password = Get-Content "Y:\Work\U_drive\creds\zamw_Encrypted.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($username,$password)

start powershell -Credential $credential