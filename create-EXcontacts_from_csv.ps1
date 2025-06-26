"This script creates EX2010 contacts from csv spreadsheet"
"Values for the script are hardcoded - so do not proceed without checking what is being done."
break
pause



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

$csv = Import-Csv -Path $ImportFilePath

# Change that bit
$OU = 'intranet.macro4.com/USRobotics/Contacts'

write-host "Contacts will be creaed in the following OU "  + $OU
pause

foreach($contact in $csv) 
{ 
New-MailContact -ExternalEmailAddress $contact.EmployeeEmail -Name $contact.DisplayName -Alias $contact.alias -FirstName $contact.FirstName -LastName $contact.LastName -OrganizationalUnit $OU
Set-Contact -identity $contact.EmployeeEmail -City $contact.City -Company $contact.Company -Department $contact.Description -CountryOrRegion $contact.Country -StateOrProvince $contact.State -StreetAddress $contact.Street -PostalCode $contact.zip -WebPage $contact.WebPage -Fax $contact.Fax -Phone $contact.TelephoneNumber -Office $contact.Office -Notes $contact.Notes
Add-DistributionGroupMember -Identity $contact.MemberOf1 -Member $contact.EmployeeEmail
Add-DistributionGroupMember -Identity $contact.MemberOf2 -Member $contact.EmployeeEmail
} 