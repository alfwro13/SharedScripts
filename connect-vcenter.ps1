if ($global:DefaultVIServers.Count -gt 0) {
""
write-host "Connection to vCenter server already established:"
$global:DefaultVIServers
""
} else
{
$vCenterIP = "10.0.24.32"
$HostName = [System.Net.Dns]::GetHostByAddress($vCenterIP).HostName
Add-PSSnapin VMware.VimAutomation.Core
#$host.ui.rawui.WindowTitle="PowerShell [PowerCLI Module Loaded]"
$CredsFile = "U:\PowershellCreds_amw.txt"
$password = get-content $CredsFile | ConvertTo-SecureString
$username = "isys\amw"
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password

"Connecting using:"
$HostName
$Cred
""
"Connecting, please wait.."

Connect-VIServer $vCenterIP -credential $cred


""
"Welcome to the VMware vSphere PowerCLI!"
""
"To find out what commands are available type:        Get-Command -PSsnapin VMware.VimAutomation.Core"
"To display all virtual machines:                     Get-VM"
""
write-host "Connection to vCenter server established:"

$global:DefaultVIServers


}