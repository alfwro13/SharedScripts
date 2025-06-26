param (
    [Parameter(Mandatory=$true)]
    [string]$UserName,
    [Parameter(Mandatory=$true)]
    [String]$GroupName
)
Write-Host "Adding specified User: " $UserName " to selected Group: " $GroupName

pause

ADD-ADGroupMember “$GroupName” –members “$UserName”

Get-ADGroup -filter {Name -eq $GroupName} | get-adgroupMember | select distinguishedName