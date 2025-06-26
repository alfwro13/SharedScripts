param (
	[Parameter(Mandatory=$true)]
	[string]$computerName
)
write-host "Adding $computerName computer to: $group.distinguishedName "
get-adcomputer $computerName | Add-ADPrincipalGroupMembership -MemberOf $group.distinguishedName