param (
    [Parameter(Mandatory=$true)]
    [string]$UserName
)
$TSGW="TSGW"
$groupID="$UserName $TSGW"
Get-ADGroup -filter {name -like $groupID} | get-adgroupMember | select Name

