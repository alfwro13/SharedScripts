$groupID="M4 Cisco Meraki Users"
write-host "The following users a member of the M4 Cisco meraki Users group:"
$result = Get-ADGroup -filter {name -like $groupID} | get-adgroupMember
$result.Name | sort

