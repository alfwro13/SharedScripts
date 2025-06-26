
$a = Invoke-Command -ComputerName m4ukprx1 { netstat -a }
$b = ($a[3..$a.count] | ConvertFrom-String | where p5 -eq "ESTABLISHED" |select -ExpandProperty p4)
$b -replace ":.*" | group | select count,name