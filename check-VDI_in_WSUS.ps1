import-module updateservices

$wsusComputers = Get-WsusServer m4uksus1 -PortNumber 8530 | Get-WsusComputer -All

$ADComputers = Get-ADComputer -filter * -Properties * | select-object name,description,operatingsystemversion,canonicalname | where canonicalname  -like "*VDI*"

ForEach ($computer in $ADComputers.name){
IF($wsusComputers.fulldomainname | select-string $computer -Quiet){}
Else
{write-host $computer "- NOT in WSUS" -BackgroundColor Yellow -ForegroundColor Black}
	}



