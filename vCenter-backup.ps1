 
 Import-Module vmware.vimautomation.core
 Import-Module vmware.vimautomation.cis.core


$vCenterIP = "10.0.24.7"
$HostName = [System.Net.Dns]::GetHostByAddress($vCenterIP).HostName

Connect-CisServer $vCenterIP -credential (Get-Credential)

pause 
"connected"

[VMware.VimAutomation.Cis.Core.Types.V1.Secret]$BackupPassword = “VMw@re123”
$Comment = “First API Backup”
$LocationType = “FTP”
$location = “ftp.macro4.net/vcsabackup-$((Get-Date).ToString(‘yyyy-MM-dd-hh-mm’))”
$LocationUser = “vmware”
[VMware.VimAutomation.Cis.Core.Types.V1.Secret]$locationPassword = “Bfa38d3d”

"vars set"


Import-Module .\vCSA-Backup-module.ps1

pause
get-module

pause


Backup-VCSAToFile -BackupPassword $BackupPassword  -LocationType $LocationType -Location $location -LocationUser $LocationUser -LocationPassword $locationPassword -Comment "This is a demo" -ShowProgress -FullBackup