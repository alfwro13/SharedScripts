param (
[Parameter(Mandatory=$true)]
[string]$computerName
)

Get-ADComputer -id $computerName -Properties * | select name,description

Invoke-Command -ComputerName $computerName -ScriptBlock { 
stop-service bits ;
stop-service wuauserv -force ;
get-service wuauserv ;
stop-service wuauserv ;
write-host "Removing SoftwareDistribution folder...." ;
remove-item -recurse c:\windows\softwaredistribution ;
write-host "Starting services ..." ;
start-service wuauserv ;
start-sleep 3 ;
get-service wuauserv ;
start-service bits ;
wuauclt /reportnow ;
start-sleep 10 ;

}