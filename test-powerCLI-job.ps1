
param (
	[Parameter(Mandatory=$true)]
	[string[]]$newVMList
	)

Y:\Work\U_drive\connect-VMware.ps1

$template = "Base-Win10-210311-lpd"

$a = Get-Datastore DEV3700_TRAIN2

Write-Host "Will deploy to" $a.name
Write-Host "There is" $a.FreeSpaceGB "GB of free space"
Write-Host "Total size is:" $a.CapacityGB "GB"

$template_hdd_size = get-template $template | get-harddisk

foreach ($drive in $template_hdd_size.capacitygb) {
		$disk_space_required += $drive
		}

write-host "Deploying" $newVMList.Count "VMs"

$total_disk = $disk_space_required * $newVMList.count

Write-Host "Required disk space:" $total_disk "GB"
""
Write-Host "Template name:" $template
""
$Folder = Get-Folder -Id Folder-group-v148095

Write-Host "Press Ctrl-C to cancel"
pause
write-host "VM deployment in progress - please wait..."
$osCust = Get-OSCustomizationSpec -name "training Template"
$resPool = Get-ResourcePool -Name "Training - New"


$taskTab = @{}
 
# Create all the VMs specified in $newVmList
foreach($Name in $newVmList){
$taskTab[(New-VM -name $Name -ResourcePool $resPool -Location $folder -Datastore DEV3700_TRAIN2 -Template $template -OSCustomizationSpec $osCust -RunAsync).Id] = $Name

}


# Start each VM that is completed
$runningTasks = $taskTab.Count
while($runningTasks -gt 0){
	Get-Task | % {
		if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
			Get-VM $taskTab[$_.Id] | Start-VM
			$taskTab.Remove($_.Id)
			$runningTasks--
		}
		elseif($taskTab.ContainsKey($_.Id) -and $_.State -eq "Error"){
			$taskTab.Remove($_.Id)
			$runningTasks--
		}
	}
	Start-Sleep -Seconds 15
}