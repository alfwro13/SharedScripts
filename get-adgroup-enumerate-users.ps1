param (
    [Parameter(Mandatory=$true)]
    [string]$GroupName
)

Get-ADGroup -filter {Name -eq $GroupName} | get-adgroupMember | select distinguishedName
""
pause
