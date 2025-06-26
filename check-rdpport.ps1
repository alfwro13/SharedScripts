Write-Host "this app will check if rdp port 3389 is enabled on specifed host"
$servername = Read-Host "enter server name"
New-Object System.Net.Sockets.TCPClient -ArgumentList "$servername",3389