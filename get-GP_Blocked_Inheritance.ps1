Add-PSSnapin Quest.ActiveRoles.ADManagement
Import-Module Grouppolicy
$domain = Read-Host "Specify domain i.e.: contoso.com"
$data = Get-QADObject -type OrganizationalUnit -SizeLimit 0 -DontUseDefaultIncludedProperties | foreach-object { Get-GPInheritance -Target $_ -Domain $domain}
$data | where {$_.GpoInheritanceBlocked -eq "Yes"} | select Path