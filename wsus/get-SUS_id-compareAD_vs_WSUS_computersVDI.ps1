Import-Module PSRemoteRegistry
import-module updateservices

$wsusComputers = Get-WsusServer m4ukwsus -PortNumber 8530 | Get-WsusComputer -All

$computers = get-adcomputer -filter 'name -like "*"' -prop * | where {$_.operatingsystem -like "*Windows 10*" -and $_.enabled -eq $true}
$computers | out-gridview

$result = @()
foreach ($computer in $computers.name)  {
	if (test-connection -BufferSize 32 -count 1 -computername $computer -quiet) {
    
    $value = Get-RegValue -ComputerName $computer -key SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -value SusClientid -ErrorVariable badoutput

    $FQDNcomputer = $computer + ".intranet.macro4.com"
    if ($wsusComputers.fulldomainname -contains $FQDNcomputer) {         
        $WSUS = "In WSUS"        
        }
        else {        
        $WSUS = "Not in WSUS"
        }


    $result	+= New-Object psobject -Property @{
                                                ComputerName = $computer
                                                SusClientID = $value.Data
                                                WSUS = $WSUS
						Error = $badoutput
                                                }

}
	else {
            $text = "computer offline or no access"
            $FQDNcomputer = $computer + ".intranet.macro4.com"
    if ($wsusComputers.fulldomainname -contains $FQDNcomputer) {         
        $WSUS = "In WSUS"        
        }
        else {        
        $WSUS = "Not in WSUS"
        }

    
		    $result	+= New-Object psobject -Property @{
                                                ComputerName = $computer
                                                SusClientID = $text
                                                WSUS = $WSUS
						Error = "n/a"
                                                }
}
}
$result | Out-GridView