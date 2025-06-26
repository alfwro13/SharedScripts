$OUName = read-host "Specify OU name string"

Get-ADComputer -filter * -Properties * | select-object name,description,operatingsystemversion,canonicalname | where canonicalname  -like "*$OUName*" | ? operatingsystemversion -like "*10.0*" | sort operatingsystemversion -Descending | ft @{expression={$_.name};Label="CompName";width=15},description,OperatingSYstemVersion
