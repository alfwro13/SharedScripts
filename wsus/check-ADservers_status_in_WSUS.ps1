import-module updateservices

$wsusComputers = Get-WsusServer m4ukwsus -PortNumber 8530 | Get-WsusComputer -All

$ADcomputers = Import-Csv -Path .\servers.csv

$result = @()
foreach ($computer in $computers.computername)  {
    
    $FQDNcomputer = $computer + ".intranet.macro4.com"

    if ($wsusComputers.fulldomainname -contains $FQDNcomputer) { 
        
        $IN = "In WSUS"

        $result	+= New-Object psobject -Property @{
                                                ComputerName = $computer
                                                WSUS = $IN
                                                }
        
        }
        else {
        
        $OUT = "Not in WSUS"

        $result	+= New-Object psobject -Property @{
                                                ComputerName = $computer
                                                WSUS = $OUT
                                                }
        
         
        }

}

$result | Out-GridView



