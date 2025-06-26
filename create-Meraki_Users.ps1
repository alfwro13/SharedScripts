
Write-Host "Create new column with OU location - Call it OU:"
write-host " 1. OU=M4 Cisco Meraki MAC Addresses,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
write-host " 2. OU=M4 Employees MAC Addresses,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
""
""
Write-Host "Create new column with OU Group membership - Call it Group:" 
write-host " 1. CN=M4 Cisco Meraki MAC Addresses,OU=Groups,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
write-host " 2. CN=M4 Employees MAC Addresses,OU=Groups,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"

$MAC_address = Read-Host "Specify MAC address"
if ( $MAC_address.length -lt 12) {
	write-host "MAC address too short"
	break
	}
if ( $MAC_address.length -gt 12) {
	write-host "MAC address too long"
	break
	}
$mac = $MAC_address.ToLower()
Write-Host "Your Mac address is: " $mac


if ($var -match "^([0-9A-Fa-f]{2}){5}([0-9A-Fa-f]{2})$" ) { write-host "true" } else {write-host "false" }
pause

#import cls

    $Users = Import-Csv U:\filename.csv
    $UPN_at_bit="intranet.macro4.com"

#create usernames
    foreach ($User in $Users)
    {
    
#check if user exists
    $Name = $user.Username
    $ADUser = Get-ADUser -LDAPFilter "(sAMAccountName=$Name)"
    If ($ADUser -eq $Null) {
        write-host $user.username "- user does not exist - processing ..." 
    

        #Assign variables from csv

        $Displayname = $User.Username
        $SAM = $User.Username
	    $Description = $User.Description
        $UPN = $User.username + "@" + $UPN_at_bit
        $Path = $User.OU
        $group = $User.Group

    #set password
        $plainpassword = $User.Password
        $password = ConvertTo-SecureString -String $plainpassword -AsPlainText -Force
	
    #create AD accounts
        New-ADUser -Name $User.Username -AccountPassword $password -Path $User.OU
        Set-ADUser -Identity $user.Username -Enabled $true -PasswordNeverExpires $true -CannotChangePassword $true -Description $user.Description -DisplayName $user.Username -UserPrincipalName $UPN
    
        
    #Add user to relevant AD group
        $Group =  Get-ADGroup $user.Group
        #$group.DistinguishedName
        add-ADGroupMember $group.DistinguishedName -members $user.Username
    #set new primary group    
        $groupSid = $group.sid
        #$groupSid
        [int]$GroupID = $groupSid.Value.Substring($groupSid.Value.LastIndexOf("-")+1)
        get-aduser $user.Username | Set-ADObject -Replace @{primaryGroupID="$groupID"}
    #remove user from Domain User group
      Remove-ADGroupMember "CN=Domain Users,OU=Domain Global Groups,DC=intranet,DC=macro4,DC=com" -Members $user.Username -Confirm:$false  
        }


Else {
    write-host $user.Username "- user already exists, skipping"
      }

        }