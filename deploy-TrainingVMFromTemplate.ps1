param (
	[Parameter(Mandatory=$true)]
	[string[]]$newVMList
	)

Y:\nc\Work\U_drive\connect-VMware.ps1

#$template = "Base-Win10-210311-lpd"

$templates = get-folder -Name "Training Templates" | Get-Template | sort
$template = $templates | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru} 
$template | ft -auto
$myTemplate = read-host "select Template ID"
$template_selection = $templates[$myTemplate]

$a = Get-Datastore FS5200_TRAINING


#if ($template_selection.Name -eq "Base-Win10-220922-lpd")
#	{
#		$osCust = Get-OSCustomizationSpec -name "training Template"
#	}
if ($template_selection.Name -eq "Base-Win11-250916v2")
	{
		$osCust = Get-OSCustomizationSpec -name "Win11_Training_Template"
	}

Write-Host "Will deploy to" $a.name
Write-Host "There is" $a.FreeSpaceGB "GB of free space"
Write-Host "Total size is:" $a.CapacityGB "GB"

$template_hdd_size = get-template $template_selection.Name | get-harddisk

foreach ($drive in $template_hdd_size.capacitygb) {
		$disk_space_required += $drive
		}

write-host "Deploying" $newVMList.Count "VMs"

$total_disk = $disk_space_required * $newVMList.count

Write-Host "Required disk space:" $total_disk "GB"
""
Write-Host "Template name:" $template_selection.Name
write-host "OsCustomization Spec:" $osCust
""
$Folder = Get-Folder -Id Folder-group-v148095

Write-Host "Press Ctrl-C to cancel"
pause
write-host "VM deployment in progress - please wait..."


$resPool = Get-ResourcePool -ID ResourcePool-resgroup-127172

#########################################################

#$taskTab = @{ }

# foreach ($Name in $newVmList) {
#     $task = New-VM -Name $Name -ResourcePool $resPool -Location $folder -Datastore FS5200_TRAINING -Template $template_selection.Name -OSCustomizationSpec $osCust -RunAsync

#     # Check if the task was created successfully
#     if ($task.Id) {
#         $taskTab[$task.Id] = $Name
#     } else {
#         Write-Host "Failed to create VM: $Name"
#     }
# }


foreach ($Name in $newVmList) {
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Deploying VM:" $Name
    $vm = New-VM -Name $Name -ResourcePool $resPool -Location $folder -Datastore FS5200_TRAINING -Template $template_selection.Name -OSCustomizationSpec $osCust
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting VM:" $Name
    Start-VM -VM $vm
}
