import-module activedirectory

$vmName = read-host "specify computer name"

Y:\Work\U_drive\connect-VMware.ps1

$note = read-host "Specify owner of this VM"
$template = "Win2016DC"

$a = Get-Datastore DEV3700_N03

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

$Folder = get-folder -id Folder-group-v58

Write-Host "Press Ctrl-C to cancel"
pause

$resPool = Get-ResourcePool -Id ResourcePool-resgroup-127511

New-VM -name $vmName -ResourcePool $resPool -Location $folder -Datastore $a -Template $template

"Powering VM On ...."
start-vm $vmName -Verbose:$false | out-null

Write-host "Wait for VM to deply then proceed"
pause
write-host "setting vSphere Note and Owner"
set-vm $vmName -Description $note -Confirm:$false
get-VM $vmName | Set-Annotation -CustomAttribute "Owner" -Value $Note

