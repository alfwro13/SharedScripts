cls
$cluster = get-cluster | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Cluster_ID -Value $counter -MemberType NoteProperty -PassThru}
$cluster | ft -auto
$clusterid = read-host "select cluster"
$VMCLUSTER = $cluster[$clusterid]


$1 = get-view -viewtype ClusterComputeResource | where name -like $vmcluster.name | select name,datastore
$table1 = @()
foreach ($datastore in $1.Datastore) {
    $table = " " | select datastore_ID,Cluster_Name
    $table.datastore_ID = $datastore
    $table.Cluster_name =  $1.Name
    $table1 += $table
    }


$datastores = Join-Object -Left $table1 -Right (Get-datastore | select id,name,FreeSpaceGB,CapacityGB) -Where { $args[0].datastore_ID -eq $args[1].id} -LeftProperties 'Cluster_Name' -RightProperties * -Type AllInLeft

$datastores | % {$counter = -1} {$counter++; $_ | Add-Member -Name Datastore_ID -Value $counter -MemberType NoteProperty -PassThru} | select Datastore_ID,Cluster_Name,Name,FreeSpaceGB,CapacityGB | ft -AutoSize

