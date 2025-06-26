$computer = read-host "Enter computer name"
$patch = read-host "Specify update KB number or enter * to list all updates"
Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $computer | select description,hotfixid,installedon | where hotfixid -eq $patch