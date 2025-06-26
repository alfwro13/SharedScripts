 $zaccount = $(whoami)
 if ($zaccount -like "isys\gis*" ) {write-host "Permissions Verified - OK" }
 else {write-host "You do not have the necessary access rights to proceed further."
 write-host "Open PowerShell session with your ISYS Z account"
 Break }


Write-Host "This script will create a TSGW security group for a specified user"
$username = Read-Host "Enter the ISYS username"
$isys_user = get-aduser $username
$computername = read-host "Specify Computer name"
$isys_comp = Get-ADComputer $computername
""
Write-host "Security Group '$username TSGW' will be created and computer account '$computername' will be added to it, then the group will be added to 'VM Remote Access TSGW'. If that is correct press ENTER otherwise press Ctrl-C"
pause
sleep 10
New-ADGroup –name “$username TSGW” –SamAccountName “$username TSWG” –GroupCategory Security –GroupScope Global –Path “OU=TSGW Access,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com” –Description  “Terminal Server GW Group for $username”

Write-Host "Security Group Created"
write-host
Write-Host "Now the user:" $username "will be added to the Group."

Add-ADPrincipalGroupMembership –identity $isys_user –MemberOf  “CN=$username TSGW,OU=TSGW Access,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com”

Write-Host "user added."
Write-Host
Write-Host "now let's add the computer account to that group. Press ENTER to proceed"
""
Get-ADComputer $isys_comp | add-ADPrincipalGroupMembership –MemberOf “CN=$username TSGW,OU=TSGW Access,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com”

write-host "Now login to TSGW server and create access policy."

#write-host "Now to finish it of we will add the $username TSGW to the VM Remote Access TSGW security group"

#Add-ADGroupMember -id 'vm remote access tsgw' -Members "CN=$username TSGW,OU=TSGW Access,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"

write-host "Job done"
$id = "$username tsgw"

get-adgroup -filter {Name -eq $id } | get-adgroupmember | select distinguishedName
