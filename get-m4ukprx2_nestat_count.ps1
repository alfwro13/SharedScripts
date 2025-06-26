
$a = Invoke-Command -ComputerName m4ukprx2 { netstat -a }
$b = ($a[3..$a.count] | ConvertFrom-String | select -ExpandProperty p4)
$b -replace ":.*" | group | select count,name