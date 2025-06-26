"This script adds Exchange Contacts to distribtion groups"
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

"Are you sure you want to go ahead?"
pause

foreach($contact in $csv) 
{ 
Add-DistributionGroupMember -Identity $contact.MemberOf1 -Member $contact.EmployeeEmail
Add-DistributionGroupMember -Identity $contact.MemberOf2 -Member $contact.EmployeeEmail
} 