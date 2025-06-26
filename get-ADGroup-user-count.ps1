param (
    [Parameter(Mandatory=$true)]
    [string]$GroupName
)

Get-ADGroup -id $GroupName -Properties * | select -ExpandProperty members | Measure-Object