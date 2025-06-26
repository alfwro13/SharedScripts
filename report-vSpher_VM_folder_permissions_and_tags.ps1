$vcenter = "10.0.24.32"

filter Get-FolderPath {
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name

        $current = Get-View $_.Parent -Server $vcenter
        $path = $_.Name
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent -Server $vcenter
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}

$report = @()
    $folders = Get-Datacenter -Server $vcenter | Get-Folder vm | Get-Folder
    foreach ($folder in $folders){ 
        $perms = Get-VIPermission -Entity $folder -Server $vcenter | Where {$_.Entity -eq $folder}
        $obj = "" | Select Folder,FolderPath,vCenter,Perm1,Role1,Perm2,Role2,Perm3,Role3,Perm4,Role4,Perm5,Role5,Perm6,Role6,Perm7,Role7,Perm8,Role8,Perm9,Role9,Perm10,Role10,Perm11,Role11,Perm12,Role12,Perm13,Role13,Perm14,Role14,Perm15,Role15
        $obj.Folder = $folder.Name
        $obj.FolderPath = ($folder | Get-FolderPath).Path
        $obj.vCenter = $vcenter
        $i = 1
        IF ($perms.Count -gt 15){Write "Permissions Count for " $folder.Name " is greater than 15."}
        foreach ($perm in $perms){
            $obj.("Perm" + $i) = $perm[0].Principal
            $obj.("Role" + $i) = $perm[0].Role
            $i++
        }
        $report += $obj
    }
$report | Sort FolderPath -Descending | Sort vCenter -Descending| Export-Csv -Path $env:USERPROFILE\Desktop\Folders_Permission_Report.csv -NoTypeInformation
	
	
	
	
	
	$VMs = Get-VM
	$report = @()
    foreach ($VM in $VMs){ 
        $perms = Get-VIPermission -Entity $vm | select * | where EntityId -Like 'VirtualMachine-vm*' #this will report only permissions that are assigned to this object i.e. are not inherited
		#$perms = Get-VIPermission -Entity $vm  # this will report all permissions
        $obj = "" | Select VM_name,Perm1,Role1,Perm2,Role2,Perm3,Role3,Perm4,Role4,Perm5,Role5,Perm6,Role6,Perm7,Role7,Perm8,Role8,Perm9,Role9,Perm10,Role10,Perm11,Role11,Perm12,Role12,Perm13,Role13,Perm14,Role14,Perm15,Role15,Perm16,Role16,Perm17,Role17,Perm18,Role18,Perm19,Role19,Perm20,Role20,Perm21,Role21,Perm22,Role22,Perm23,Role23,Perm24,Role24,Perm25,Role25,Perm26,Role26,Perm27,Role27,Perm28,Role28,Perm29,Role29
        $obj.VM_name = $vm.Name
        $i = 1
        IF ($perms.Count -gt 29){Write "Permissions Count for " $vm.Name " is greater than 29."}
        foreach ($perm in $perms){
            $obj.("Perm" + $i) = $perm[0].Principal
            $obj.("Role" + $i) = $perm[0].Role
            $i++
        }
        $report += $obj
    }
$report | Sort VM_name -Descending | Export-Csv -Path $env:USERPROFILE\Desktop\VMs_Permissions_Non-inherited_Report.csv -NoTypeInformation



    $VMS = get-vm 
    $Report =@()
    foreach ($vm in $VMS) {
       $row = "" | Select VMName, Notes, Attribute, Value, Attribute1, Value1, Tag
       $row.VMname = $vm.Name
       $row.Notes = $vm | select -ExpandProperty Notes
       $customattribs = $vm | select -ExpandProperty CustomFields
       $row.Attribute = $customattribs[0].Attribute
       $row.Value = $customattribs[0].value
       $row.Attribute1 = $customattribs[1].Attribute
       $row.Value1 = $customattribs[1].value
      $row.Tag = $vm | Get-Tagassignment | select tag     
       $Report += $row
    }
     $report | Export-Csv $env:USERPROFILE\Desktop\tags_report.csv –NoTypeInformation

	 
	$VMs = Get-VM
	$report = @()
    foreach ($VM in $VMs){ 
        #$perms = Get-VIPermission -Entity $vm | select * | where EntityId -Like 'VirtualMachine-vm*' #this will report only permissions that are assigned to this object i.e. are not inherited
		$perms = Get-VIPermission -Entity $vm  # this will report all permissions
        $obj = "" | Select VM_name,Perm1,Role1,Perm2,Role2,Perm3,Role3,Perm4,Role4,Perm5,Role5,Perm6,Role6,Perm7,Role7,Perm8,Role8,Perm9,Role9,Perm10,Role10,Perm11,Role11,Perm12,Role12,Perm13,Role13,Perm14,Role14,Perm15,Role15,Perm16,Role16,Perm17,Role17,Perm18,Role18,Perm19,Role19,Perm20,Role20,Perm21,Role21,Perm22,Role22,Perm23,Role23,Perm24,Role24,Perm25,Role25,Perm26,Role26,Perm27,Role27,Perm28,Role28,Perm29,Role29
        $obj.VM_name = $vm.Name
        $i = 1
        IF ($perms.Count -gt 29){Write "Permissions Count for " $vm.Name " is greater than 29."}
        foreach ($perm in $perms){
            $obj.("Perm" + $i) = $perm[0].Principal
            $obj.("Role" + $i) = $perm[0].Role
            $i++
        }
        $report += $obj
    }
$report | Sort VM_name -Descending | Export-Csv -Path $env:USERPROFILE\Desktop\VMs_Permissions_All_Report.csv -NoTypeInformation