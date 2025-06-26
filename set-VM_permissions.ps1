$vmname = read-host "Enter Virtual Machine name"
$username = read-host "Enter User name (i.e. vsphere.unicom\abc)"

$roles = Get-VIRole | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$roles | ft -auto
$myRole = read-host "select Role ID"
$role_selection = $roles[$myRole]

get-vm $vmname | New-VIPermission -Role (Get-VIRole -Name $role_selection.name) -Principal $username
Get-vipermission $vmname