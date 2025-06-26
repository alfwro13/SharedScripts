$username = read-host "Enter User name (i.e. vsphere.unicom\abc)"

Get-VIPermission (get-vm) | where {$_.principal -eq "$username"} | select entity,role,principal