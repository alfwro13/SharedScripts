Y:\work\U_drive\connect-vmware.ps1
import-module updateservices

$a = get-vm m4tc*

$poweredoff = $a | where powerstate -eq "PoweredOff" 

$updating = $a | get-vmguest | where state -eq "NotRunning" | select vm,state,IPaddress 
$updatingString = $updating | out-string

if (($updating.vm -ne $null) -and ($updating.PowerState -eq "PoweredOn") ){
	foreach ($vm in $updating)
		{
		$MoRef = (Get-VM $vm.vm.name).ExtensionData.MoRef.Value
		Start-Process -FilePath "https://m4ukvc06/screen?id=$MoRef"
		}
	}

$locked = Search-ADAccount -LockedOut | where name -NotLike "Administrator" | select Name,LastLogonDate | out-string
 $filterdate = (get-date).adddays(-360).date 
$expired = Search-ADAccount -AccountExpired | where accountexpirationdate -ge $filterdate | select name,AccountExpirationDate | sort accountexpirationdate | out-string

$wsus = Get-WsusServer m4uksus1 -PortNumber 8530 | Get-WsusComputer -ComputerTargetGroups "unassigned computers" | out-string

$raport=@"


-------------
Powered OFF VDIs:
$poweredoff

-------------
Possibly updating or VM tools issue:
$updatingString

-------------
Locked accounts:
$locked

-------------
Accounts expired in the last 12 months:
$expired

-------------
WSUS Unassigned Computers:
$wsus

"@

$raport





