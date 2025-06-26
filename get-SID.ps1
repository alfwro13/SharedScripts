$key = Get-Item HKLM:\security\sam\domains\account
$values = Get-ItemProperty $key.pspath
$bytearray = $values.V
New-Object System.Security.Principal.SecurityIdentifier($bytearray[272..295],0) | Format-List *
