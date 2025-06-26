param (
	[Parameter(Mandatory=$true)]
	[string]$groupName
)
write-host "Use * if you are using partial group name"
$group=get-adgroup -filter {name -like $groupName}
$group
write-host "New variable created `$group.distinguishedName "
