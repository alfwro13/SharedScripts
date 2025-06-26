$logName = "security"
$pcName = "m4ukdc14", "m4dedc03", "m4ukdc15"
$eventID = "4740"
Get-EventLog -LogName $logName -ComputerName $pcName | where {$_.eventID -eq $eventID} `
| select -Property timegenerated, replacementstrings, message | Out-GridView