Import-Module PSRemoteRegistry
$computers = Import-Csv -Path .\servers.csv

$result = @()
foreach ($computer in $computers.computername)  {
	if (test-connection -BufferSize 32 -count 1 -computername $computer -quiet) {
    
    $value = Get-RegValue -ComputerName $computer -key SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -value SusClientid

    $result	+= New-Object psobject -Property @{
                                                ComputerName = $value.ComputerName
                                                SusClientID = $value.Data
                                                }

}
	else {
            $text = "computer offline or no access"
    
		    $result	+= New-Object psobject -Property @{
                                                ComputerName = $computer
                                                SusClientID = $text
                                                }
}
}






$result | Out-GridView