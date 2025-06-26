write-host "Restarting connector on prx1...."
Invoke-Command -ComputerName m4ukprx1 -ScriptBlock { Restart-Service connector }
Start-Sleep 20
write-host "Restarting connector on prx2...."
Invoke-Command -ComputerName m4ukprx2 -ScriptBlock { Restart-Service connector }
start-sleep 10
write-host "Connector Status:"
Invoke-Command -ComputerName m4ukprx1,m4ukprx2 -ScriptBlock { get-service connector }
