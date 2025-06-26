cls
$cluster = get-cluster | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Cluster_ID -Value $counter -MemberType NoteProperty -PassThru}
$cluster | ft -auto
$clusterid = read-host "select cluster"
$VMCLUSTER = $cluster[$clusterid]


$DomainControllerVMName = "m4ukdc14.intranet.macro4.com"
$VMNAME = Read-Host "Specify VM Name"
$CPU = Read-Host "Number of CPUs"
$MemoryGB = Read-Host "Specify the size of RAM in GBs"
$DiskGB = Read-Host "Specify the size of Disk in GBs"

#Select Resource Pool
$rp = Get-Cluster | ? name -like $vmcluster.name | Get-ResourcePool | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name RP_ID -Value $counter -MemberType NoteProperty -PassThru} 
$rp | ft -auto
$rpid = read-host "select resource pool (enter RP_ID number)"
$resourcePool = $rp[$rpid]

# Select Datastore
$1 = get-view -viewtype ClusterComputeResource | where name -like $vmcluster.name | select name,datastore
$table1 = @()
foreach ($datastore in $1.Datastore) {
    $table = " " | select datastore_ID,Cluster_Name
    $table.datastore_ID = $datastore
    $table.Cluster_name =  $1.Name
    $table1 += $table
    }

$datastores = Join-Object -Left $table1 -Right (Get-datastore | select id,name,FreeSpaceGB,CapacityGB) -Where { $args[0].datastore_ID -eq $args[1].id} -LeftProperties 'Cluster_Name' -RightProperties * -Type AllInLeft
$datastores | % {$counter = -1} {$counter++; $_ | Add-Member -Name Datastore_ID -Value $counter -MemberType NoteProperty -PassThru} | select Datastore_ID,Cluster_Name,Name,FreeSpaceGB,CapacityGB | Sort-Object FreeSpaceGB -Descending | ft -AutoSize
$datastoreid = read-host "Select Datastore (enter Datastore_ID)"
$selected_datastore = $datastores[$datastoreid]

#Select Network
$network = Get-VirtualPortGroup | Where-Object {($_.Name -NotLike "*Management*") -and ($_.VLanId -gt 0)} | select Name -Unique | % {$counter = -1} {$counter++; $_ | Add-Member -Name Network_ID -Value $counter -MemberType NoteProperty -PassThru}
$network | ft -AutoSize
$networkid = Read-Host "Select Network (enter network ID)"
$selected_network = $network[$networkid]

# Select Folder Location


New-VM -Name $VMNAME -ResourcePool $resourcePool.Name -Datastore $selected_datastore.Name -NetworkName $selected_network.Name -Version v10 -MemoryGB $MemoryGB -DiskGB $DiskGB -DiskStorageFormat Thin -CD 

get-vm $VMNAME | get-networkadapter | Set-NetworkAdapter -Type e1000 -Confirm:$false | Out-Null
get-VM $VMNAME | Get-ScsiController | Set-ScsiController -Type VirtualLsiLogicSAS -Confirm:$false | Out-Null


#Enabling Upgrade VM Tools on Restart
Write-Host "Enabling the 'Check and upgrade VMtools during power cycling' option."
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.changeVersion = $VMNAME.ExtensionData.Config.ChangeVersion
$spec.tools = New-Object VMware.Vim.ToolsConfigInfo
$spec.tools.toolsUpgradePolicy = "upgradeAtPowerCycle"
 
$_this = Get-View -Id $VMNAME.Id
$_this.ReconfigVM_Task($spec)

#Enable Memory and CPU hot add
#$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.memoryHotAddEnabled = $true
$spec.cpuHotAddEnabled = $true
$VMNAME.ExtensionData.ReconfigVM_Task($spec)



function VDI_mount_ISO {
    $ISO = dir 'vmstores:\m4ukvc05@443\United Kingdom\Crawley\DS3512_006\ISO' | select Name | % {$counter = -1} {$counter++; $_ | Add-Member -Name ISO_ID -Value $counter -MemberType NoteProperty -PassThru}
    $ISO | ft -auto
    $ISOid = read-host "Select ISO file that you want to mount (select ID)"
    $VMISO = $ISO[$ISOid]
    $ISO_Root = "[DS3512_006] ISO/"
    $ISO_Full_Name = $ISO_Root + $VMISO.Name
    Set-CDDrive -VM $VMNAME -StartConnected -IsoPath $ISO_Full_Name
}


$AskMountCD = Read-Host "Mount CD Y/N (VDIs only) ? "
if ($AskMountCD -eq "Y") { VDI_mount_ISO }
    else {}

"Job Done"
"Powering VM On ...."
 start-vm $VMNAME -Verbose:$false | out-null



 
