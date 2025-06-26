$vCenterIP = "10.0.61.29"

if ($defaultVIServer.Name -eq $vCenterIP) {
	""
	write-host "Connection to vCenter server already established"
	""
	$defaultVIServer
	""
	} else
		{
	import-module VMware.VumAutomation
	$HostName = [System.Net.Dns]::GetHostByAddress($vCenterIP).HostName
#catpure creds use:
#
#read-host -assecurestring | convertfrom-securestring | out-file C:\mysecurestring.txt
#	
$username = "amw@intranet.macro4.com"
$password = Get-Content "Y:\NC\Work\U_drive\creds\enc.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($username,$password)


	"Connecting to"
	$HostName
	""
	"Connecting, please wait.."

	Connect-VIServer $vCenterIP -credential $credential
		}
