import-module activedirectory


$last = Get-ADComputer -Filter 'name -like "m4tc2*"' | sort | select -Last 1 name
write-host "Last compuer  name used: " $last.name

$vmName = read-host "specify computer name"

try {
get-adcomputer $vmname -ErrorAction stop | out-null
  $result = $true
  }
catch {
$result = $false }

if ($result -eq $true ) {
write-host "Computer name already exists"
exit

} else 
{write-host "Checked - VM does not exist in Active Directory - all good"
}

Y:\NC\Work\U_drive\connect-VMware.ps1

$note = read-host "Specify owner of this VM"
$template = "Win11_template"

$a = Get-Datastore FS5200_VDI_SYSTEMS

Write-Host "Will deploy to" $a.name
Write-Host "There is" $a.FreeSpaceGB "GB of free space"
Write-Host "Total size is:" $a.CapacityGB "GB"

$template_hdd_size = get-template $template | get-harddisk

foreach ($drive in $template_hdd_size.capacitygb) {
		$disk_space_required += $drive
		}
Write-Host "Required disk space:" $disk_space_required "GB"
""
""
write-host "Do you want to go ahead?"

$Folder = get-folder -id Folder-group-v286

Write-Host "Press Ctrl-C to cancel"
pause

$osCust = Get-OSCustomizationSpec -name "Win11-VDI-template"
$resPool = Get-ResourcePool -ID ResourcePool-resgroup-127172

New-VM -name $vmName -Location $folder -ResourcePool $resPool -Datastore $a -Template $template -OSCustomizationSpec $osCust

"Powering VM On ...."
start-vm $vmName -Verbose:$false | out-null

Write-host "Wait for VM to deply then proceed"
pause
write-host "setting vSphere Note and Owner"
set-vm $vmName -Description $note -Confirm:$false
get-VM $vmName | Set-Annotation -CustomAttribute "Owner" -Value $Note
get-adcomputer $vmname
pause
Set-ADComputer $vmName -Description $Note

Write-host "moving computer object to VDI OU"
get-adcomputer $vmName | Move-ADObject -targetPath "OU=VDI,OU=Windows 11,OU=Desktops,OU=Computers,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
