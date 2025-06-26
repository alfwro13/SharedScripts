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

$report | Sort FolderPath -Descending | Sort vCenter -Descending| Export-Csv -Path $env:USERPROFILE\Desktop\Folders_Permission_Report.csv
