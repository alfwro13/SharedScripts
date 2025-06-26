Write-host "this script will update the msNPAllowDialIn vaule to allow user to connect to macro4 VPN"
$user = Read-Host "what is the user name"
Set-ADUser $user -replace @{msNPallowDialIn=$true}


