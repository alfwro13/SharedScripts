$groupID="M4 Cisco Meraki MAC Addresses"
$result = Get-ADGroup -filter {name -like $groupID} | get-adgroupMember
$groupID
foreach($name in $result.name)
{
get-aduser $name -prop * | select DistinguishedName,PrimaryGroup
}

""
""
""
""

$groupID="M4 Employees MAC Addresses"
$result = Get-ADGroup -filter {name -like $groupID} | get-adgroupMember
$groupID
foreach($name in $result.name)
{
get-aduser $name -prop * | select DistinguishedName,PrimaryGroup

}