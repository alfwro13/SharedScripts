 $user = $(whoami)
 if ($user -like "isys\z*" ) {write-host "Permissions Verified - OK"
 }
 else {write-host "You do not have the necessary access rights to proceed further."
 write-host "Starting Your Admin powershell session" -BackgroundColor Yellow -ForegroundColor red
 .\powershell.ps1
 exit
 }

write-host "This script assumes that the user AD account has already been created"
$username = read-host "Enter user three letter username"
$id = get-aduser $username -prop *
write-host "You have entered:" $id.Name
""
pause

"Now select mailbox database"
"Here is the list of all available databases:"
get-MailboxDatabase

$database = read-host "Enter the Name of the database"

pause
write-host "The following parameters will be used when creating the mailbox:" -BackgroundColor Cyan -ForegroundColor Black
write-host "Alias:" $id.SamAccountName -BackgroundColor Cyan -ForegroundColor Black
write-host "Database:" $database -BackgroundColor Cyan -ForegroundColor Black
$retentionPolicy = 'UnicomGlobal Retention Policy' 
write-host "Retention Policy:" $retentionPolicy -BackgroundColor Cyan -ForegroundColor Black
""
"Please press ENTER to set up the account.... or Ctrl-C to abort"
pause

Enable-Mailbox -Identity $id.CanonicalName -Alias $id.SamAccountName -Database $database -RetentionPolicy $retentionPolicy
set-mailbox -Identity $id.CanonicalName -EmailAddressPolicyEnabled $false
Set-CASmailbox -Identity $id -IMAPEnabled $false
""
""
write-host "Job Done:"
get-mailbox $id.CanonicalName | select Name,Alias,ServerName,Database,RetentionPolicy,EmailAddressPolicyEnabled,EmailAddresses
pause
cls




