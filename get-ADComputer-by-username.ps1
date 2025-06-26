param (
    [Parameter(Mandatory=$true)]
    [string]$Name_or_Surname
)

Get-ADComputer -Filter * -Properties * | where {$_.description -like "*$Name_or_Surname*"} | select name,description | fl