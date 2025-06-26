$Servername = Read-Host "Enter the Servername" 
$PortNumber = Read-Host "Enter the Port Number" 
$K = U:\PortQryUI\PortQry.exe -n $Servername -e $PortNumber -p both
$L = $K -Match "LIS?" 
If($L -ne $null) 
{ 
$res = $servername + " has port " + $PortNumber + " Opened" 
Write-Host $res 
write-host
write-host $L

 
} 
Else 
{ 
$res = $servername + " has port " + $PortNumber + " Closed" 
Write-Host $res 
write-host
write-host $L
}