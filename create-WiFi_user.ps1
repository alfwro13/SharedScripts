$OU_work="OU=Mobile Device MACs - Company,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
$OU_personal="OU=Mobile Device MACs - Employee,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"

$Group_work="CN=Macro 4 MAC - Company,OU=Groups,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
$group_personal="CN=Macro 4 MAC - Employee,OU=Groups,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"


$MAC_address=""
$mac=""
Write-Host "Specify MAC address without any spaces, : or -, i.e 22bb33cc44dd"
"For testing use existing: 44783E4E7AE6 "
$MAC_address = Read-Host "MAC address "
if ( $MAC_address.length -lt 12) {
	write-host "MAC address too short"
	break
	}
if ( $MAC_address.length -gt 12) {
	write-host "MAC address too long"
	break
	}
if ($MAC_address -match "^([0-9A-Fa-f]{2}){5}([0-9A-Fa-f]{2})$" ) { write-host "Your MAC address seems valid - " $MAC_address  } 
else { 
Write-Host "Invalid character in the string provided - this is not a valid MAC address" 
break 
}

$mac = $MAC_address.ToLower()

    
$UPN_at_bit="intranet.macro4.com"

#check if user exists
    $Name = $mac
    $ADUser = Get-ADUser -LDAPFilter "(sAMAccountName=$Name)"
    If ($ADUser -eq $Null) {
        write-host $user.username "- user does not exist - processing ..." 

        $Displayname = $mac
        $SAM = $mac

        write-host "Specify description: ie. Name Surname - Samsung 1c"
	    $Description = read-host " "
        $UPN = $mac + "@" + $UPN_at_bit
    
        Write-host "Is this a work or a personal device" 
        Write-Host "1. Work "
        Write-Host "2. Personal "
        $1 = read-host "Select 1 or 2"
        if ($1 -eq 1) { 
        Write-host "account will be added to:"
        "OU in AD: OU=M4 Cisco Meraki MAC Addresses,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
        "Security Group: CN=M4 Cisco Meraki MAC Addresses,OU=Groups,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
        $Path = $OU_work 
        $Usergroup = $Group_work
        } 
        else { 
        Write-host "account will be added to:"
        "OU in AD: OU=M4 Employees MAC Addresses,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
        "Security Group: CN=M4 Employees MAC Addresses,OU=Groups,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
        $Path = $OU_personal
        $UserGroup =$group_personal
        }

    #temp password
        $plainpassword_temp = "JamDoughnut123!"
        $password_temp = ConvertTo-SecureString -String $plainpassword_temp -AsPlainText -Force


    #set password
        $plainpassword = $mac
        $password = ConvertTo-SecureString -String $plainpassword -AsPlainText -Force


    #create AD accounts
        New-ADUser -Name $mac -AccountPassword $password_temp -Path $path
        Set-ADUser -Identity $mac -Enabled $true -PasswordNeverExpires $true -CannotChangePassword $true -Description $Description -DisplayName $mac -UserPrincipalName $UPN
    
        
    #Add user to relevant AD group
        $Group =  Get-ADGroup $userGroup
        #$group.DistinguishedName
        add-ADGroupMember $group.DistinguishedName -members $mac
    #set new primary group    
        $groupSid = $group.sid
        #$groupSid
        [int]$GroupID = $groupSid.Value.Substring($groupSid.Value.LastIndexOf("-")+1)
        "I'm hard at work - nearly done....."
        Start-Sleep -s 20
	"Setting new Primary Group."
        get-aduser $mac | Set-ADObject -Replace @{primaryGroupID="$groupID"}
    #remove user from Domain User group
    	"Removing Domain Users group form the account..."
      Remove-ADGroupMember "CN=Domain Users,OU=Domain Global Groups,DC=intranet,DC=macro4,DC=com" -Members $mac -Confirm:$false  
      ""
      ""
      ""
      Write-host "JOB DONE" -BackgroundColor Yellow -ForegroundColor Black
      ""
      ""
      get-aduser $mac -Properties * | select DisplayName,Description,CanonicalName,PasswordNeverExpires,Enabled,CannotChangePassword
      ""
      "Group Membership"
      get-aduser $mac -Properties * | select -ExpandProperty memberof

      Set-ADAccountPassword $mac -NewPassword $password -Reset

       }
  Else {
    write-host $mac "- user already exists, skipping"

      get-aduser $mac -Properties * | select DisplayName,Description,CanonicalName,PasswordNeverExpires,Enabled,CannotChangePassword
      ""
      "Group Membership"
      get-aduser $mac -Properties * | select -ExpandProperty memberof
      }
