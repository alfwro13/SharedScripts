echo "This script will:"
echo "1. Create the distribution group"
echo "2. Disable email policy"
echo "3. unselect only Authorized senders thingy"
echo "4. Set Alias and Managedby"
echo "5. And finally will add users to the group"
echo ""
echo "if that is not what you want press ctrl-c"
pause

#Distribtuion Group Name
$groupName = Read-Host "Specify the Distribution Group Name "
$alias = Read-Host "Specify the group Alias "
$displayName = Read-Host "Specify the Display Name "
$managedBy = Read-Host "This group is Managed by "
$accounts = (Read-Host "If you want to add users to this Distribution Group please list here (comma separated) ").split(',') | ForEach-Object {$_.trim()}

# Create the distribution group
New-DistributionGroup -name $GroupName -Alias $alias -DisplayName $displayName -ManagedBy $managedBy

# Unselect the Automatically upate e-mail addresses based on e-mail address policy
Set-DistributionGroup -EmailAddressPolicyEnabled $false -Identity $groupName

# Unselect the Require that all senders are authenticated check box
Set-DistributionGroup -RequireSenderAuthenticationEnabled $false -Identity $groupName

foreach ($account in $accounts) {
add-DistributionGroupMember -id "$groupName" -member $account
}

Get-DistributionGroupMember -id $groupName


echo ""
echo "*************************************** DONE **************************************************************"
echo "Group Created - email policy disabled, the Require that all senders are authenticated check box unselected."
echo ""
echo "To add users use: "
echo "add-DistributionGroupMember -id `"$groupName`" -member name.surname"
echo "To list users: "
echo "Get-DistributionGroupMember -id `"$groupName`" "
