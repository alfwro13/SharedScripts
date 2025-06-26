param (
    [Parameter(Mandatory=$true)]
    [string]$Name_OR_Surname
)
Get-ADUser -Filter "name -like '*$Name_OR_Surname*'" | select name,samaccountname
