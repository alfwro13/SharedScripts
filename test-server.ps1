## Test-Server.ps1
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ServerName
)
 
foreach ($name in $ServerName) {
    [pscustomobject]@{
        ServerName = $name
        PingAvailable = (Test-Connection -ComputerName $name -Quiet -Count 1)
        ServiceRunning = (Get-Service -Name 'wuauserv' -ComputerName $name).Status -eq 'Running'
        PortOpen = (Test-NetConnection -ComputerName $name -CommonTCPPort HTTP).TcpTestSucceeded
    }
}

