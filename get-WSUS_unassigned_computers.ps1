import-module updateservices

Get-WsusServer m4uksus1 -PortNumber 8530 | Get-WsusComputer -ComputerTargetGroups "unassigned computers"