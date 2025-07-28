
# Get all clusters and sort them
$clusters = Get-Cluster | Sort-Object Name

# Add an index (Cluster_ID) to each cluster for selection
$clusterList = $clusters | Select-Object Name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}

# Display list of clusters with IDs
$clusterList | Format-Table -AutoSize

# Prompt user to select a cluster by ID
$myCluster = Read-Host "Select Cluster ID"

# Get the selected cluster object
$selectedCluster = $clusters[$myCluster]
Write-Host "You selected cluster: $($selectedCluster.Name)"

get-cluster $selectedCluster | Get-VM | Select-Object Name,@{Name='Owner';Expression={ ($_ | Get-Annotation -CustomAttribute 'Owner').Value }} #| out-gridview

