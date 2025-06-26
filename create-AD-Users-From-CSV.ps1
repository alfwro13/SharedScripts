 #
 # Permission Checker
 #
 $zaccount = $(whoami)
 if ($zaccount -like "isys\z*" ) {write-host "Permissions Verified - OK"
 }
 else {write-host "You do not have the necessary access rights to proceed further."
 write-host "Open PowerShell session with your ISYS Z account"
 Break
 }
 #
 # Establishing Exchange Connection
 #
"Connecting to Exchange server...."
$cas1 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://m4ukcas1/PowerShell/ -Authentication Kerberos   
import-PSsession $cas1
Clear-Host
Get-PSSession | ft
#
# File import and check
#
$ImportFilePath = read-host "Enter the full path to the CSV file. i.e.: C:\users.csv" 
"Checking file..."
$strFileName=$ImportFilePath
If (Test-Path $strFileName){
 "File exists - OK"
}Else{
  "Sorry specified File " + $ImportFilePath + " does not exist"
  Break  
}
pause

$Users = Import-Csv -Path $ImportFilePath

#
#  Simple Active Directory OU selector
#
do {
cls
$FindOU = read-host "Specify AD OU where the accounts will be placed, i.e. UK Crawley"
$OrgUnit = Get-ADOrganizationalUnit -Filter {name -like $FindOU }
write-host "Your selection   " $OrgUnit
$again = Read-Host "Is that correct?(y/n)"
}
while ($again -ne "Y")

$EXretentionPolicy = 'UnicomGlobal Retention Policy'  # Hardcoded EX retention policy

#
# Exchange DB Selector
#
"Now select the Exchange mailbox database"
"Available databases:"
get-MailboxDatabase
$EXdatabase =  read-host "Your DB Selection:"

#
# Print main variables 
#
Write-Host "File imported:" $ImportFilePath -BackgroundColor Cyan -ForegroundColor Black
write-host "OU selected:" $OrgUnit.DistinguishedName -BackgroundColor Cyan -ForegroundColor Black
write-host "Selected Exchange 2010 Database:" $EXdatabase -BackgroundColor Cyan -ForegroundColor Black
write-host "Selected Retention Policy:" $EXretentionPolicy -BackgroundColor Cyan -ForegroundColor Black
""
"Please press ENTER to proceed .... or Ctrl-C to abort"
pause

#
# Main script loop
# Sets variables based on the csv file
# then it creates AD user account/mailbox for each row 
# and prints summary
#
$UPN_at_bit="intranet.macro4.com"
foreach ($User in $Users)            
{            
    $Displayname = $User.Displayname            
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname            
    $OU = $OrgUnit.DistinguishedName      
    $Alias = $User.Alias  
    $SAM = $User.UserLoginName
    $UPN = $User.Firstname + "." + $User.Lastname + "@" + $UPN_at_bit
    $SMTP = $User.EmailAddress 
    $Password = $User.DomainPassword
    $Country = 	$User.Country
    New-Mailbox -Name $Displayname -Alias $Alias -UserPrincipalName $UPN -SamAccountName $SAM -FirstName "$UserFirstname" -LastName "$UserLastname" -Password (ConvertTo-SecureString $Password -AsPlainText -Force) -OrganizationalUnit $OU -ResetPasswordOnNextLogon $false -Database $EXdatabase -RetentionPolicy $EXretentionPolicy > $null
    set-mailbox -Identity $SAM -emailAddresses $SMTP -EmailAddressPolicyEnabled $false >$null
	Set-User -identity $SAM
    Get-Mailbox $SAM  | select Name,Alias,PrimarySmtpAddress | Format-Table
    }

Get-PSSession | Remove-PSSession

    