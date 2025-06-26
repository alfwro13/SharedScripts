param (
	[Parameter(Mandatory=$true)]
	[string]$ComputerName
)

qwinsta /server:$ComputerName
""
$session = read-host "Which session ID do you wan to logoff"
logoff $session /server:$ComputerName

if($?) {            
Write-Host "Session logged off successfully"            
} else {            
write-host "Logoff failed"            
}