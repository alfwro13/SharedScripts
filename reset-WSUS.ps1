param (
[Parameter(Mandatory=$true)]
[string]$computerName
)

Get-ADComputer -id $computerName -Properties * | select name,description

Invoke-Command -ComputerName $computerName -ScriptBlock { 
stop-service bits ;
stop-service wuauserv -force ;
get-service wuauserv ;
stop-service cryptSvc ;
stop-service msiserver ;
stop-service wuauserv ;
write-host "Removing SoftwareDistribution folder...." ;
remove-item -recurse c:\windows\softwaredistribution ;
remove-item -recurse C:\Windows\System32\Catroot2 ;
write-host "Starting services ..." ;
start-service wuauserv ;
start-service cryptSvc ;
start-service msiserver ;
start-sleep 3 ;
get-service wuauserv ;
start-service bits ;
wuauclt /reportnow ;
start-sleep 10 ;
get-WindowsUpdateLog ;
get-content -tail 100 $ENV:UserProfile\Desktop\WindowsUpdate.log ;
write-host "Job done - DO NOT forget to remove" $computerName "from the WSUS cosole" ;
wuauclt /detectnow;
}