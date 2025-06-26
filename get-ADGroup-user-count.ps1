param (
    [Parameter(Mandatory=$true)]
    [string]$GroupName
)
#write-host
#write-host "This script will give you user count number for a given security group"
#$GroupName = read-host "Enter Active Directory Security Group"
Get-ADGroup -id $GroupName -Properties * | select -ExpandProperty members | Measure-Object