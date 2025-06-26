"M4UKPRX1"
$a = Invoke-Command -ComputerName m4ukprx1 { netstat -a }
$b = ($a[3..$a.count] | ConvertFrom-String | where p5 -eq "ESTABLISHED" |select -ExpandProperty p4)
$b -replace ":.*" | group | select count,name

"M4UKPRX2"
$a = Invoke-Command -ComputerName m4ukprx2 { netstat -a }
$b = ($a[3..$a.count] | ConvertFrom-String | where p5 -eq "ESTABLISHED" |select -ExpandProperty p4)
$b -replace ":.*" | group | select count,name

"M4UKPRX4"
$a = Invoke-Command -ComputerName m4ukprx4 { netstat -a }
$b = ($a[3..$a.count] | ConvertFrom-String | where p5 -eq "ESTABLISHED" |select -ExpandProperty p4)
$b -replace ":.*" | group | select count,name

"M4UKPRX5"
$a = Invoke-Command -ComputerName m4ukprx5 { netstat -a }
$b = ($a[3..$a.count] | ConvertFrom-String | where p5 -eq "ESTABLISHED" |select -ExpandProperty p4)
$b -replace ":.*" | group | select count,name