
$csv = Import-Csv C:\list1.csv 
foreach($contact in $csv) 
{ 
Get-mailContact $contact.EmployeeEmail | Set-MailContact -EmailAddressPolicyEnabled $false -EmailAddresses $contact.EmployeeEmail
} 