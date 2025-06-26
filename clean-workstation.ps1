$WorkstationName = Read-Host "Please enter the name of your workstation/server you wish to clean"
Write-Host "You have entered" $WorkstationName "as your workstation"

pause

invoke-command -ComputerName $WorkstationName -ScriptBlock { Remove-Item "E:\Users\*\AppData\Local\Temp\*" -force -recurse }

invoke-command -ComputerName $WorkstationName -ScriptBlock { Remove-Item "C:\Windows\Temp\*" -force -recurse }

invoke-command -ComputerName $WorkstationName -ScriptBlock { Remove-Item "C:\Temp\*" -force -recurse }

invoke-command -ComputerName $WorkstationName -ScriptBlock { net stop wuauserv }

invoke-command -ComputerName $WorkstationName -ScriptBlock { Remove-Item "C:\Windows\SoftwareDistribution\*" -force -Recurse }

invoke-command -ComputerName $WorkstationName -ScriptBlock { net start wuauserv }

invoke-command -ComputerName $WorkstationName -ScriptBlock { dism /online /cleanup-image /spsuperseded }